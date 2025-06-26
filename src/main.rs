use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use colored::Colorize;
use git2::{Repository, StatusOptions};
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use tracing::info;

#[derive(Parser)]
#[command(name = "git-wtree")]
#[command(about = "A convenient git worktree wrapper", version)]
#[command(after_help = get_help_footer())]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Create a new worktree
    Add {
        /// Branch name or path
        branch: String,
        /// Optional path for the worktree (defaults to ../branch-name)
        path: Option<String>,
    },
    /// List all worktrees
    #[command(alias = "ls")]
    List,
    /// Show navigation guide to a worktree
    Go {
        /// Worktree name or branch name
        name: String,
        /// Print only the worktree path (for shell integration)
        #[arg(long)]
        print_path: bool,
    },
    /// Remove a worktree
    #[command(alias = "rm")]
    Remove {
        /// Worktree name or branch name
        name: String,
    },
    /// Show status of all worktrees
    Status,
    /// Clean up missing worktrees
    Clean,
    /// Navigate to git repository root
    #[command(name = "goroot")]
    GoRoot {
        /// Print only the root path (for shell integration)
        #[arg(long)]
        print_path: bool,
    },
}

fn get_help_footer() -> &'static str {
    let current_dir = env::current_dir().unwrap_or_default();
    let worktree_base = env::var("GIT_WTREE_BASE").unwrap_or_else(|_| {
        if let Ok(repo) = Repository::open(&current_dir) {
            if let Ok(git_root) = find_git_root(&repo) {
                return git_root.join(".worktree").to_string_lossy().to_string();
            }
        }
        String::from("(git root)/.worktree")
    });
    
    // Static string is required for clap, so we use a lazy static
    Box::leak(format!(
        "\nCurrent Settings:\n  Working Directory: {}\n  Worktree Base: {}\n  GIT_WTREE_BASE: {}",
        current_dir.display(),
        worktree_base,
        env::var("GIT_WTREE_BASE").unwrap_or_else(|_| "(not set)".to_string())
    ).into_boxed_str())
}

fn find_git_root(repo: &Repository) -> Result<PathBuf> {
    // Get the path to the .git directory
    let git_path = repo.path();
    
    // If it's a regular repository (not a worktree), the parent of .git is the root
    if git_path.file_name() == Some(std::ffi::OsStr::new(".git")) {
        git_path.parent()
            .map(|p| p.to_path_buf())
            .context("Cannot get parent of .git directory")
    } else {
        // For worktrees, we need to find the common directory
        // The common directory is stored in the repository
        if let Ok(common_dir) = fs::read_to_string(repo.path().join("commondir")) {
            // commondir contains path to the main .git directory
            let common_path = PathBuf::from(common_dir.trim());
            common_path.parent()
                .map(|p| p.to_path_buf())
                .context("Cannot get parent of common directory")
        } else {
            // Fallback to workdir
            repo.workdir()
                .map(|p| p.to_path_buf())
                .context("Cannot get working directory")
        }
    }
}

fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::from_default_env()
                .add_directive(tracing::Level::INFO.into()),
        )
        .init();

    let cli = Cli::parse();

    match cli.command {
        Commands::Add { branch, path } => add_worktree(&branch, path),
        Commands::List => list_worktrees(),
        Commands::Go { name, print_path } => go_to_worktree(&name, print_path),
        Commands::Remove { name } => remove_worktree(&name),
        Commands::Status => show_status(),
        Commands::Clean => clean_worktrees(),
        Commands::GoRoot { print_path } => go_to_root(print_path),
    }
}

fn add_worktree(branch: &str, custom_path: Option<String>) -> Result<()> {
    let repo = Repository::open_from_env()
        .context("Not in a git repository")?;
    
    // Determine the path for the new worktree
    let path = if let Some(p) = custom_path {
        PathBuf::from(p)
    } else {
        let base_path = if let Ok(base) = env::var("GIT_WTREE_BASE") {
            PathBuf::from(base)
        } else {
            // Find git root directory (where .git is located)
            let git_root = find_git_root(&repo)?;
            git_root.join(".worktree")
        };
        
        // Convert branch name to directory name (e.g., feature/auth -> auth)
        let dir_name = branch.split('/').last().unwrap_or(branch);
        base_path.join(dir_name)
    };

    info!("Creating worktree at: {}", path.display());

    // Ensure parent directory exists
    if let Some(parent) = path.parent() {
        if !parent.exists() {
            fs::create_dir_all(parent)
                .with_context(|| format!("Failed to create directory: {}", parent.display()))?;
            println!(
                "{}",
                format!("✓ Created directory: {}", parent.display()).green()
            );
        }
    }

    // Check if branch exists
    let branch_exists = repo.find_branch(branch, git2::BranchType::Local).is_ok();
    
    // Create worktree with sanitized name (replace / with - for worktree identifier)
    let worktree_name = branch.replace('/', "-");
    
    // Create the worktree using git2-rs
    if branch_exists {
        // For existing branch, set the reference to the branch
        let branch_ref = repo.find_branch(branch, git2::BranchType::Local)?;
        let branch_ref = branch_ref.get();
        
        let mut opts = git2::WorktreeAddOptions::new();
        opts.reference(Some(&branch_ref));
        
        repo.worktree(
            &worktree_name,
            &path,
            Some(&opts),
        )?;
    } else {
        // For new branch, create worktree first, then create branch
        let opts = git2::WorktreeAddOptions::new();
        
        // Create the worktree
        repo.worktree(
            &worktree_name,
            &path,
            Some(&opts),
        )?;
        
        // Open the new worktree repository and create the new branch
        let wt_repo = Repository::open(&path)?;
        let head = wt_repo.head()?.peel_to_commit()?;
        let new_branch = wt_repo.branch(branch, &head, false)?;
        wt_repo.set_head(new_branch.get().name().unwrap())?;
        wt_repo.checkout_head(Some(git2::build::CheckoutBuilder::default().force()))?;
    }

    println!(
        "{}",
        format!("✓ Created worktree '{}' at {}", 
            branch, 
            path.display()
        ).green()
    );

    Ok(())
}

fn list_worktrees() -> Result<()> {
    let repo = Repository::open_from_env()
        .context("Not in a git repository")?;
    
    println!("{}", "Worktrees:".bold());
    
    // List main worktree
    let main_path = repo.workdir()
        .context("Cannot get main repository path")?;
    let head = repo.head()?;
    let branch = head.shorthand().unwrap_or("HEAD");
    let commit = head.peel_to_commit()?;
    
    println!(
        "  {} {} ({})",
        "[main]".green().bold(),
        main_path.display(),
        format!("{} {}", 
            branch.blue(), 
            &commit.id().to_string()[..7].dimmed()
        )
    );
    
    // List other worktrees
    let worktrees = repo.worktrees()?;
    for i in 0..worktrees.len() {
        if let Some(name_str) = worktrees.get(i) {
            let wt = repo.find_worktree(name_str)?;
            let wt_repo = Repository::open(wt.path())?;
            
            if let Ok(head) = wt_repo.head() {
                let branch = head.shorthand().unwrap_or("HEAD");
                let commit = head.peel_to_commit()?;
                
                println!(
                    "  {} {} ({})",
                    format!("[{}]", name_str).blue(),
                    wt.path().display(),
                    format!("{} {}", 
                        branch.blue(), 
                        &commit.id().to_string()[..7].dimmed()
                    )
                );
            };
        }
    }
    
    Ok(())
}

fn go_to_worktree(name: &str, print_path: bool) -> Result<()> {
    let repo = Repository::open_from_env()
        .context("Not in a git repository")?;
    
    // Try to find worktree by name
    let mut found_path = None;
    
    // Check if it's the main worktree
    if name == "main" {
        found_path = repo.workdir().map(|p| p.to_path_buf());
    } else {
        // Search in worktrees
        let worktrees = repo.worktrees()?;
        for i in 0..worktrees.len() {
            if let Some(wt_name_str) = worktrees.get(i) {
                if wt_name_str == name || wt_name_str.contains(name) {
                    let wt = repo.find_worktree(wt_name_str)?;
                    found_path = Some(wt.path().to_path_buf());
                    break;
                }
            }
        }
        
        // If not found, try to match by branch name
        if found_path.is_none() {
            let worktrees = repo.worktrees()?;
            for i in 0..worktrees.len() {
                if let Some(wt_name_str) = worktrees.get(i) {
                    let wt = repo.find_worktree(wt_name_str)?;
                    let wt_repo = Repository::open(wt.path())?;
                    
                    if let Ok(head) = wt_repo.head() {
                        if let Some(branch) = head.shorthand() {
                            if branch == name || branch.contains(name) {
                                found_path = Some(wt.path().to_path_buf());
                                break;
                            }
                        }
                    };
                }
            }
        }
    }
    
    if let Some(path) = found_path {
        if print_path {
            // Print only the path for shell integration
            println!("{}", path.display());
        } else {
            println!("{}", "To navigate to this worktree, run:".green());
            println!("  cd {}", path.display());
        }
    } else {
        if print_path {
            // When using --print-path, return with an error code but no output
            std::process::exit(1);
        } else {
            println!("{}", format!("Worktree '{}' not found", name).red());
            println!("\nAvailable worktrees:");
            list_worktrees()?;
        }
    }
    
    Ok(())
}

fn go_to_root(print_path: bool) -> Result<()> {
    let repo = Repository::open_from_env()
        .context("Not in a git repository")?;
    
    // Get the root directory of the git repository
    let root_path = find_git_root(&repo)?;
    
    if print_path {
        // Print only the path for shell integration
        println!("{}", root_path.display());
    } else {
        println!("{}", "To navigate to the git repository root, run:".green());
        println!("  cd {}", root_path.display());
    }
    
    Ok(())
}

fn remove_worktree(name: &str) -> Result<()> {
    let repo = Repository::open_from_env()
        .context("Not in a git repository")?;
    
    // Find the worktree
    let mut found = false;
    let worktrees = repo.worktrees()?;
    for i in 0..worktrees.len() {
        if let Some(wt_name_str) = worktrees.get(i) {
            if wt_name_str == name || wt_name_str.contains(name) {
                // Remove the worktree
                let wt = repo.find_worktree(wt_name_str)?;
                wt.prune(None)?;
                
                println!(
                    "{}",
                    format!("✓ Removed worktree '{}'", wt_name_str).green()
                );
                found = true;
                break;
            }
        }
    }
    
    if !found {
        println!("{}", format!("Worktree '{}' not found", name).red());
    }
    
    Ok(())
}

fn show_status() -> Result<()> {
    let repo = Repository::open_from_env()
        .context("Not in a git repository")?;
    
    println!("{}", "Worktree Status:".bold());
    
    // Check main worktree
    let main_path = repo.workdir()
        .context("Cannot get main repository path")?;
    print_worktree_status(&repo, "main", main_path)?;
    
    // Check other worktrees
    let worktrees = repo.worktrees()?;
    for i in 0..worktrees.len() {
        if let Some(name_str) = worktrees.get(i) {
            let wt = repo.find_worktree(name_str)?;
            let path = wt.path();
            
            if path.exists() {
                let wt_repo = Repository::open(path)?;
                print_worktree_status(&wt_repo, name_str, path)?;
            } else {
                println!(
                    "  {} {} - {}",
                    format!("[{}]", name_str).red(),
                    path.display(),
                    "Directory missing!".red()
                );
            }
        }
    }
    
    Ok(())
}

fn print_worktree_status(repo: &Repository, name: &str, path: &Path) -> Result<()> {
    let mut opts = StatusOptions::new();
    opts.include_untracked(true);
    
    let statuses = repo.statuses(Some(&mut opts))?;
    let changes_count = statuses.len();
    
    let status_str = if changes_count == 0 {
        "clean".green()
    } else {
        format!("{} changes", changes_count).yellow()
    };
    
    let head = repo.head()?;
    let branch = head.shorthand().unwrap_or("HEAD");
    
    println!(
        "  {} {} ({}) - {}",
        if name == "main" {
            format!("[{}]", name).green()
        } else {
            format!("[{}]", name).blue()
        },
        path.display(),
        branch.blue(),
        status_str
    );
    
    Ok(())
}

fn clean_worktrees() -> Result<()> {
    let repo = Repository::open_from_env()
        .context("Not in a git repository")?;
    
    let mut cleaned = 0;
    
    // Check each worktree
    let worktrees = repo.worktrees()?;
    for i in 0..worktrees.len() {
        if let Some(name_str) = worktrees.get(i) {
            let wt = repo.find_worktree(name_str)?;
            let path = wt.path();
            
            if !path.exists() {
                // Prune missing worktree
                wt.prune(None)?;
                println!(
                    "{}",
                    format!("✓ Cleaned up missing worktree '{}'", name_str).green()
                );
                cleaned += 1;
            }
        }
    }
    
    if cleaned == 0 {
        println!("{}", "No worktrees to clean up".green());
    } else {
        println!(
            "{}",
            format!("✓ Cleaned up {} worktree(s)", cleaned).green()
        );
    }
    
    Ok(())
}
#!/usr/bin/env python3
"""在项目根目录生成 .zed/debug.json 和 .zed/tasks.json"""
import json
import os


def main():
    module = input("Python module path (e.g. my_app.main): ").strip()
    if not module:
        print("Aborted")
        return

    pkg = module.split(".")[0]
    port = input("Port [8000]: ").strip() or "8000"
    has_args = input("Add 'Run with Args' task? [y/N]: ").strip().lower() == "y"

    debug = [
        {
            "label": f"Python: Module ({pkg})",
            "adapter": "Debugpy",
            "request": "launch",
            "python": "$ZED_WORKTREE_ROOT/.venv/bin/python",
            "module": module,
            "cwd": "$ZED_WORKTREE_ROOT",
            "console": "integratedTerminal",
            "justMyCode": True,
        },
        {
            "label": f"FastAPI: uvicorn ({pkg})",
            "adapter": "Debugpy",
            "request": "launch",
            "python": "$ZED_WORKTREE_ROOT/.venv/bin/python",
            "module": "uvicorn",
            "args": [f"{module}:app", "--host", "127.0.0.1", "--port", port, "--reload"],
            "cwd": "$ZED_WORKTREE_ROOT",
            "console": "integratedTerminal",
            "justMyCode": True,
        },
    ]

    tasks = [
        {
            "label": f"FastAPI: Uvicorn ({pkg})",
            "command": "$ZED_WORKTREE_ROOT/.venv/bin/python",
            "args": ["-m", "uvicorn", f"{module}:app", "--host", "127.0.0.1", "--port", port, "--reload"],
            "cwd": "$ZED_WORKTREE_ROOT",
            "use_new_terminal": False,
            "allow_concurrent_runs": False,
            "reveal": "always",
            "reveal_target": "dock",
            "hide": "never",
            "shell": "system",
        },
    ]

    if has_args:
        debug.append({
            "label": f"Python: Module with Args ({pkg}, edit args)",
            "adapter": "Debugpy",
            "request": "launch",
            "python": "$ZED_WORKTREE_ROOT/.venv/bin/python",
            "module": module,
            "args": ["--example", "value"],
            "cwd": "$ZED_WORKTREE_ROOT",
            "console": "integratedTerminal",
            "justMyCode": True,
        })
        tasks.append({
            "label": f"Python: Run Module with Args ({pkg}, edit args)",
            "command": "$ZED_WORKTREE_ROOT/.venv/bin/python",
            "args": ["-m", module, "--example", "value"],
            "cwd": "$ZED_WORKTREE_ROOT",
            "use_new_terminal": False,
            "allow_concurrent_runs": False,
            "reveal": "always",
            "reveal_target": "dock",
            "hide": "never",
            "shell": "system",
        })

    zed_dir = os.path.join(os.getcwd(), ".zed")
    os.makedirs(zed_dir, exist_ok=True)

    debug_path = os.path.join(zed_dir, "debug.json")
    with open(debug_path, "w") as f:
        json.dump(debug, f, indent=2)
        f.write("\n")
    print(f"Created {debug_path}")

    tasks_path = os.path.join(zed_dir, "tasks.json")
    with open(tasks_path, "w") as f:
        json.dump(tasks, f, indent=2)
        f.write("\n")
    print(f"Created {tasks_path}")


if __name__ == "__main__":
    main()

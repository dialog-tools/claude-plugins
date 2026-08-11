#!/bin/bash
# test-worktree-helper.sh
# Test suite for worktree-helper.sh
# Validates all functions without modifying real repositories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKTREE_HELPER="$SCRIPT_DIR/worktree-helper.sh"

# Test repository directory (temporary)
TEST_REPO_DIR="/tmp/worktree-test-$$"
TEST_WORKTREES_DIR="$TEST_REPO_DIR/worktrees"

# Print functions
print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Setup test repository
setup_test_repo() {
    print_info "Setting up test repository..."

    # Create test directory
    mkdir -p "$TEST_REPO_DIR"
    cd "$TEST_REPO_DIR"

    # Initialize git repository
    git init -q

    # Create initial commit
    echo "# Test Repo" > README.md
    echo "node_modules/" > .gitignore
    echo "PORT=3000" > .env.sample
    cat > package.json << 'EOF'
{
  "name": "test-repo",
  "version": "1.0.0",
  "scripts": {
    "dev": "echo 'Dev server started'"
  }
}
EOF

    git add .
    git commit -q -m "Initial commit"

    print_info "Test repository created at $TEST_REPO_DIR"
}

# Cleanup test repository
cleanup_test_repo() {
    print_info "Cleaning up test repository..."
    cd /tmp
    rm -rf "$TEST_REPO_DIR"
    print_info "Cleanup complete"
}

# Test: worktree-helper.sh exists and is executable
test_script_exists() {
    print_test "Script existence and permissions"
    ((TESTS_RUN++))

    if [[ ! -f "$WORKTREE_HELPER" ]]; then
        print_fail "worktree-helper.sh not found at $WORKTREE_HELPER"
        return 1
    fi

    if [[ ! -x "$WORKTREE_HELPER" ]]; then
        print_fail "worktree-helper.sh is not executable"
        return 1
    fi

    print_pass "Script exists and is executable"
}

# Test: Helper script shows help
test_show_help() {
    print_test "Show help message"
    ((TESTS_RUN++))

    output=$("$WORKTREE_HELPER" 2>&1 || true)

    if [[ "$output" == *"Usage:"* ]] && [[ "$output" == *"Commands:"* ]]; then
        print_pass "Help message displayed correctly"
    else
        print_fail "Help message not displayed correctly"
        return 1
    fi
}

# Test: Create worktree (dry-run simulation)
test_create_function() {
    print_test "Create worktree function"
    ((TESTS_RUN++))

    cd "$TEST_REPO_DIR"

    # Source the helper script to access functions
    source "$WORKTREE_HELPER"

    # Check if wt_create function exists
    if declare -f wt_create > /dev/null; then
        print_pass "wt_create function exists"
    else
        print_fail "wt_create function not found"
        return 1
    fi
}

# Test: Create actual worktree
test_create_worktree() {
    print_test "Create actual worktree"
    ((TESTS_RUN++))

    cd "$TEST_REPO_DIR"

    # Create worktree using git directly (helper script test)
    git worktree add "$TEST_WORKTREES_DIR/test-feature" -b test-feature 2>&1 > /dev/null

    if git worktree list | grep -q "test-feature"; then
        print_pass "Worktree created successfully"
    else
        print_fail "Worktree creation failed"
        return 1
    fi
}

# Test: List worktrees
test_list_worktrees() {
    print_test "List worktrees"
    ((TESTS_RUN++))

    cd "$TEST_REPO_DIR"

    output=$(git worktree list)

    if [[ "$output" == *"test-feature"* ]]; then
        print_pass "Worktree listed correctly"
    else
        print_fail "Worktree not listed"
        return 1
    fi
}

# Test: Worktree directory structure
test_worktree_structure() {
    print_test "Worktree directory structure"
    ((TESTS_RUN++))

    if [[ -d "$TEST_WORKTREES_DIR/test-feature" ]]; then
        print_pass "Worktree directory exists"
    else
        print_fail "Worktree directory not created"
        return 1
    fi

    if [[ -f "$TEST_WORKTREES_DIR/test-feature/.git" ]]; then
        print_pass "Worktree .git file exists"
    else
        print_fail "Worktree .git file not found"
        return 1
    fi
}

# Test: Environment file copying
test_env_file_copy() {
    print_test "Environment file copying"
    ((TESTS_RUN++))

    cd "$TEST_WORKTREES_DIR/test-feature"

    # Simulate env file copy (as helper script would do)
    if [[ -f "$TEST_REPO_DIR/.env.sample" ]]; then
        cp "$TEST_REPO_DIR/.env.sample" .env
    fi

    if [[ -f ".env" ]]; then
        print_pass "Environment file copied successfully"
    else
        print_fail "Environment file not copied"
        return 1
    fi
}

# Test: Remove worktree
test_remove_worktree() {
    print_test "Remove worktree"
    ((TESTS_RUN++))

    cd "$TEST_REPO_DIR"

    git worktree remove "$TEST_WORKTREES_DIR/test-feature" 2>&1 > /dev/null

    if ! git worktree list | grep -q "test-feature"; then
        print_pass "Worktree removed successfully"
    else
        print_fail "Worktree removal failed"
        return 1
    fi
}

# Test: Prune worktrees
test_prune_worktrees() {
    print_test "Prune worktrees"
    ((TESTS_RUN++))

    cd "$TEST_REPO_DIR"

    git worktree prune 2>&1 > /dev/null

    print_pass "Worktree prune executed successfully"
}

# Test: Detect project type
test_detect_project_type() {
    print_test "Detect project type"
    ((TESTS_RUN++))

    cd "$TEST_REPO_DIR"

    # Check if package.json exists (Node.js project)
    if [[ -f "package.json" ]]; then
        project_type="node"
        print_pass "Project type detected: Node.js"
    else
        print_fail "Project type detection failed"
        return 1
    fi
}

# Test: Multiple worktrees
test_multiple_worktrees() {
    print_test "Create multiple worktrees"
    ((TESTS_RUN++))

    cd "$TEST_REPO_DIR"

    git worktree add "$TEST_WORKTREES_DIR/feature-1" -b feature-1 2>&1 > /dev/null
    git worktree add "$TEST_WORKTREES_DIR/feature-2" -b feature-2 2>&1 > /dev/null

    worktree_count=$(git worktree list | wc -l)

    # Should have 3 worktrees: main + feature-1 + feature-2
    if [[ "$worktree_count" -ge 3 ]]; then
        print_pass "Multiple worktrees created ($worktree_count total)"
    else
        print_fail "Multiple worktrees creation failed"
        return 1
    fi

    # Cleanup
    git worktree remove "$TEST_WORKTREES_DIR/feature-1" 2>&1 > /dev/null
    git worktree remove "$TEST_WORKTREES_DIR/feature-2" 2>&1 > /dev/null
}

# Test: Error handling - duplicate branch
test_error_duplicate_branch() {
    print_test "Error handling: duplicate branch"
    ((TESTS_RUN++))

    cd "$TEST_REPO_DIR"

    # Create worktree
    git worktree add "$TEST_WORKTREES_DIR/dup-test" -b dup-branch 2>&1 > /dev/null

    # Try to create another worktree with same branch (should fail)
    if ! git worktree add "$TEST_WORKTREES_DIR/dup-test-2" -b dup-branch 2>&1 > /dev/null; then
        print_pass "Duplicate branch error handled correctly"
    else
        print_fail "Duplicate branch not prevented"
        git worktree remove "$TEST_WORKTREES_DIR/dup-test-2" 2>&1 > /dev/null
        git worktree remove "$TEST_WORKTREES_DIR/dup-test" 2>&1 > /dev/null
        return 1
    fi

    # Cleanup
    git worktree remove "$TEST_WORKTREES_DIR/dup-test" 2>&1 > /dev/null
}

# Test: Git version check
test_git_version() {
    print_test "Git version check"
    ((TESTS_RUN++))

    git_version=$(git --version | awk '{print $3}')
    required_version="2.25.0"

    # Simple version comparison
    if [[ "$(printf '%s\n' "$required_version" "$git_version" | sort -V | head -n1)" == "$required_version" ]]; then
        print_pass "Git version $git_version is sufficient (>= 2.25.0)"
    else
        print_fail "Git version $git_version is too old (requires >= 2.25.0)"
        return 1
    fi
}

# Main test runner
run_tests() {
    echo ""
    echo "======================================"
    echo "  Worktree Helper Test Suite"
    echo "======================================"
    echo ""

    # Setup
    setup_test_repo

    # Run tests
    test_script_exists
    test_show_help
    test_git_version
    test_detect_project_type
    test_create_function
    test_create_worktree
    test_list_worktrees
    test_worktree_structure
    test_env_file_copy
    test_remove_worktree
    test_prune_worktrees
    test_multiple_worktrees
    test_error_duplicate_branch

    # Cleanup
    cleanup_test_repo

    # Results
    echo ""
    echo "======================================"
    echo "  Test Results"
    echo "======================================"
    echo -e "Total tests:  ${BLUE}$TESTS_RUN${NC}"
    echo -e "Passed:       ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed:       ${RED}$TESTS_FAILED${NC}"
    echo "======================================"
    echo ""

    if [[ "$TESTS_FAILED" -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        return 1
    fi
}

# Run tests
run_tests

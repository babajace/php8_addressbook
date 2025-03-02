#!/bin/bash

# Step 0: Ensure the script is running in a Git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Not a git repository. Initializing..."
    git init
    git remote add origin https://github.com/babajace/php8_addressbook.git
    git fetch origin
    git checkout -b master origin/master
fi

# Step 1: Static Code Analysis
echo "Running PHPStan..."
composer require --dev phpstan/phpstan --quiet
vendor/bin/phpstan analyse addressbook --level=max

echo "Running PHP_CodeSniffer with increased memory limit..."
composer require --dev squizlabs/php_codesniffer --quiet
vendor/bin/phpcs -d memory_limit=512M addressbook

# Step 2: Apply Fixes
echo "Running PHP-CS-Fixer with environment check ignored..."
composer require --dev friendsofphp/php-cs-fixer --quiet
PHP_CS_FIXER_IGNORE_ENV=1 vendor/bin/php-cs-fixer fix addressbook

# Step 3: Commit and Create Pull Request
echo "Committing changes..."
git checkout -b autofix
git add .
git commit -m "Apply autofixes based on static code analysis"
git push origin autofix

# Step 4: Create Pull Request
echo "Creating pull request..."
gh pr create --title "Autofix based on static code analysis" --body "This pull request applies automatic fixes based on static code analysis using PHPStan, PHP_CodeSniffer, and PHP-CS-Fixer." --base master --head autofix

echo "Autofix process completed."
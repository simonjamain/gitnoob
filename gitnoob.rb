require 'optparse'
require 'colorize'
# helps adopting good practices and pushing clean code
# features :
# - prevents from coding directly into dev
# - prevents from pushing breaking code into dev
# - helps you setting up a standardised workflow


FEATURE_COMMIT_PREFIX = 'feature-'
REFERENCE_BRANCH_NAME = 'dev'
CURRENT_BRANCH = `git rev-parse --abbrev-ref HEAD`.delete("\n")

#-------------- START HELPERS ----------------
class String
  def is_integer?
    self.to_i.to_s == self
  end
  
  def is_positive_integer?
    self.is_integer? && self.to_i >= 0
  end
end

def error(isSuccess, message)
  unless isSuccess then
    puts "ERROR: #{message}".red
    exit
  end
end

def success(message)
  puts message.green
end

def generateFullCommitMessage(currentBranch, message)
  "#{CURRENT_BRANCH}: #{message}"
end

def generateFullFeatureBranchName(name)
  "#{FEATURE_COMMIT_PREFIX}#{name}"
end

def isWorkingDirectoryClean
  `git status --porcelain`.empty?
end

def isCurrentBranchFeature
  #TODO: also check if it descends directly from REFERENCE_BRANCH_NAME branch
  CURRENT_BRANCH.start_with?(FEATURE_COMMIT_PREFIX)
end

def isCurrentBranchReferenceBranch
  #TODO: also check if it descends directly from REFERENCE_BRANCH_NAME branch
  CURRENT_BRANCH == REFERENCE_BRANCH_NAME
end

def isBranchOnlyLocal
  #TODO: also check if it descends directly from REFERENCE_BRANCH_NAME branch
  CURRENT_BRANCH.start_with?(FEATURE_COMMIT_PREFIX)
end
#-------------- END HELPERS ----------------

#-------------- START OPTIONS LOGIC ----------------

def optionPrune
  # check if current branch is a feature 
  error(isCurrentBranchFeature, 'You cannot commit from something else than a feature branch')
  # check if working directory clean
  error(isWorkingDirectoryClean, 'Working directory is not clean')
  # test your modifications with the changes of the reference branch
  error(system('git fetch'), 'Error fetching from origin')
  error(system("git merge #{REFERENCE_BRANCH_NAME} -m \"Applying finished feature #{CURRENT_BRANCH}\""), 'Error merging')
  error(system('rake test'), 'The tests are not passing, please fix and try again')
  # apply your modifications and remove the feature branch
  error(system("git checkout #{REFERENCE_BRANCH_NAME}"), "Failed to checkout #{REFERENCE_BRANCH_NAME}")
  error(system("git merge #{CURRENT_BRANCH}"), "Failed to merge your work on #{REFERENCE_BRANCH_NAME}")
  error(system("git branch -d #{CURRENT_BRANCH}"), "Failed to remove your feature branch")
  error(system("git push"), "Failed to push the changes")
  
  success "Feature successfully applied to #{REFERENCE_BRANCH_NAME}"
end

def optionUpdate#check if working directory clean?
  # check if current branch is a feature 
  error(isCurrentBranchFeature, 'You cannot update something else than a feature branch')
  # integrate changes from the reference branch
  error(system("git rebase #{REFERENCE_BRANCH_NAME}"), 'Error rebasing')
  
  success "Feature successfully updated with #{REFERENCE_BRANCH_NAME} changes"
end

def optionFeature
  def isfeatureNameValid(name)
    !name.start_with? FEATURE_COMMIT_PREFIX
  end
  
  def createNewFeature(name)
    # validate branch name
    error(isfeatureNameValid(name), "Feature name is invalid (#{name}), it should not start with #{FEATURE_COMMIT_PREFIX}")
    # create the new branch with an appropriate name
    error(system("git checkout -b #{generateFullFeatureBranchName(name)}"), 'Failed to create branch')
  end
  
  # ensure that we are on reference branch NOTE: should we try to checkout reference branch?
  error(CURRENT_BRANCH == REFERENCE_BRANCH_NAME, "Feature must branch from #{REFERENCE_BRANCH_NAME} (currently #{CURRENT_BRANCH})")
  # check if working directory clean
  error(isWorkingDirectoryClean, 'Working directory is not clean')
  # fetching changes
  error(system('git fetch'), 'Error fetching from origin')
      
  branches = `git for-each-ref --format='%(refname)' refs/heads/`.to_s.split("\n")
  featureBranches = branches.select{|branchName| branchName.start_with?('refs/heads/feature-')}
  featureBranches.collect! {|fullName| fullName['refs/heads/'.length..-1]}
  featureBranches.insert(0, 'créer une nouvelle feature')
  featureBranches.each_with_index do |featureBranchName, index|
    puts(index.to_s + ' ' + featureBranchName)
  end
  
  puts 'choix?'
  
  choice = gets.strip
  error(choice.is_positive_integer?, 'Veuillez rentrer un nombre entier')
  
  choice_i = choice.to_i
  error((0..featureBranches.length-1).cover?(choice_i) , 'Choix non valide')
  
  if choice_i == 0
    # créer nouvelle feature
    puts 'Quel est le nom de la nouvelle feature?'
    name = gets.strip
    createNewFeature name
    
    success "Feature #{generateFullFeatureBranchName(name)} successfully created"
  else
    # basculer sur la feature existante
    error(system("git checkout #{featureBranches[choice_i]}"), "Failed to switch to feature #{featureBranches[choice_i]}")
    
    success "Switched to feature #{featureBranches[choice_i]}"
  end
end

def optionCommit(message)
  # check if current branch is a feature 
  error(isCurrentBranchFeature, 'You cannot commit from something else than a feature branch')
  # check if directory is not clean
  error(!isWorkingDirectoryClean, 'Working directory is clean')
  # add all and commit
  system 'git add -A'
  error(system("git commit -m \"#{generateFullCommitMessage(CURRENT_BRANCH, message)}\""), 'Failed to commit')
  
  success "Changes successfully commited"
end

def optionVersion
  # ensure being in reference branch
  error(isCurrentBranchReferenceBranch, 'You are not in the reference branch')
  # check if working directory clean
  error(isWorkingDirectoryClean, 'Working directory is not clean')
  # test again your modifications with the changes of the master branch
  error(system('git fetch'), 'Error fetching from origin')
  error(system("git merge master"), 'Error merging')
  error(system('rake test'), 'The tests are not passing, please fix and try again')
  # apply your modifications and go back to dev
  error(system("git checkout master"), "Failed to checkout master")
  error(system("git merge #{REFERENCE_BRANCH_NAME}"), "Failed to merge your work on master")
  error(system("git push"), "Failed to push the changes")
  error(system("git checkout #{REFERENCE_BRANCH_NAME}"), "Failed to checkout #{REFERENCE_BRANCH_NAME}")
  
  success "Successfully updated master"
end

def optionReference
  # ensure being in a branch feature
  error(isCurrentBranchFeature, 'You are not in a feature branch')
  # add all changes
  system 'git add -A'
  # check if directory is clean
  error(isWorkingDirectoryClean, 'Working directory is not clean, please stash or commit')
  # move to reference branch
  error(system("git checkout #{REFERENCE_BRANCH_NAME}"), "Failed to checkout reference branch (#{REFERENCE_BRANCH_NAME})")
  # pull latest changes
  error(system('git fetch'), 'Failed to fetch changes')
  
  success "Back to reference branch"
end

def optionHelp(options)
  puts options
end

#-------------- END OPTIONS LOGIC ----------------
optionParser = OptionParser.new do|options|

  options.on('-p', '--prune', 'Try to merge and push the current branch into the reference branch (! the feature branch get deleted after this operation)') do# check if working directory clean
    optionPrune
    exit
  end
  
  options.on('-u', '--update', 'Update feature with latest changes from the reference branche') do
    optionUpdate
    exit
  end

  options.on('-f', '--feature', 'Start developping a new or existing feature' ) do
    optionFeature
    exit
  end
  
  options.on('-c', '--commit MESSAGE', 'Stag and commit all changes to your current feature branch' ) do |message|
    optionCommit message
    exit
  end

  options.on('-r', '--reference', 'go back to reference branch') do
    optionReference
    exit
  end
  
  options.on('-v', '--version', 'publish reference branch to master') do
    optionVersion
    exit
  end

  options.on_tail( '-h', '--help', 'Display this screen' ) do
    optionHelp options
    exit
  end
end

optionParser.parse!

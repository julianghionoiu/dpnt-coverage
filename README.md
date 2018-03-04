# dpnt-coverage
Collect coverage from SRCS files

# Directories
The main directories for this code

- cloudformation
  Contains cloudformation definition for ECS cluster that runs the tests and collect coverage.
- docker
  Contains docker definition for ECS image for running the test and collect the coverage.
- lambda
  Contains lambda definition that receives the SRCS files and execute the cloudformation to run the coverage.

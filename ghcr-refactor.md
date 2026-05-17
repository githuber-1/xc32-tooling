# Creating xc32-dockerfile with GitHub Container Registry
This is a toolchain repo used to build a Docker Container Image for use in Github Actions CI/CD pipelines.

# Motivation:
- We cannot store the xc32 compiler in a normal repo because there is a file size limit for GitHub which is 100MB.

- We cannot store the xc32 compiler in git lfs because it's massive (1.5GB even when zipped) and git lfs has bandwidth limits which would be triggered very quickly.

- Usually docker images can pull in large files via direct download links with wget, but in this case, I couldn't find a link provided by Microchip

# Solution:
Leverage the fact that docker images cache files if they do not change and store the compiler in the docker image. This requires doing a local build of a docker image, and then pushing it to GitHub Container Registry where it can be accessed by GitHub Action Pipelines that need it.

# Process:
Generate a Personal Access Token (classic) from GitHub with `write:packages`, `read:packages`, and `delete:packages` scope, this is done via `Settings > Developer Tools > Personal Access Tokens > Tokens (classic)` in Github Settings. 

```bash
# Generate the token
export CR_PAT=YOUR_TOKEN
# If you run your docker commands via sudo, this command must have sudo prepended to the docker cmd. Note the typical ghcr.io endpoint does not work since this our GitHub instance in enterprise 
echo $CR_PAT | docker login github.cislunar.dibsecure.com -u YOUR_GITHUB_USERNAME --password-stdin

# Build and push the docker image. Note this requires sudo, or the user to be added to docker group.
docker build -t github.cislunar.dibsecure.com/YOUR_USER/xc32-base:latest -f xc32.Dockerfile .
docker push github.cislunar.dibsecure.com/YOUR_USER/xc32-base:latest
```

# Use
For repos that need to use this image, ensure that they have the proper permissions in Github. This is achieved by finding the xc32-base repo, and adding any dependent repos to it in `Package Settings` with `read` role.

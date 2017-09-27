This repo contains tools for creating presentations as well as my own presentations created using these tools.

# Create slideshows, run in the cloud

Easily create slides using [reveal.js](https://github.com/hakimel/reveal.js/) and run your presentation in the cloud using [Azure Container Instances](https://docs.microsoft.com/en-us/azure/container-instances/)

## Usage
Prerequisite: [Azure CLI 2.0 must be installed](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

Using powershell:
```powershell
deployRG.ps1 -deck my-awesome-presentation
```

To update your slides while the app is running:
```powershell
upload.ps1 -deck my-awesome-presentation -openBrowser
```

To delete resource group
```powershell
deleteRG.ps1 -deck my-awesome-presentation
```

Run locally (requires [Docker](https://www.docker.com/))
```powershell
runLocal.ps1 -deck my-awesome-presentation -openBrowser
```
OR (without Powershell)

```
docker run -d -v "<paht-to-deck>:/slides/" -p 8000:8000 "danidemi/docker-reveal.js:latest"
```

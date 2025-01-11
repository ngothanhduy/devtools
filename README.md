# Jenkins Controller - Docker Image 
Use to build a custom docker image for Jenkins controller

# Get list of plugin

```
Jenkins.instance.pluginManager.plugins.each{
  plugin -> 
    println ("${plugin.getShortName()}:${plugin.getVersion()}")
}
```
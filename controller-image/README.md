# Get list of plugin

Jenkins.instance.pluginManager.plugins.each{
  plugin -> 
    println ("${plugin.getShortName()}:${plugin.getVersion()}")
}
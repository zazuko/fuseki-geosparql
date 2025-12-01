---
"fuseki-geosparql": major
---

Upgrade Apache Jena to 5.6.

#### Breaking changes

Please read the following points to update your setup accordingly, as your setup might be impacted by these changes:

- The `[main]` section in `shiro.ini` should contain the following lines:

  ```
  statelessSessionManager = org.apache.shiro.web.session.mgt.DefaultWebSessionManager
  securityManager.sessionManager = $statelessSessionManager
  ```

- In case you are not using the default entrypoint script, you might need to update the way the Fuseki server is started. The class to use is now `org.apache.jena.fuseki.main.cmds.FusekiServerCmd` instead of `org.apache.jena.fuseki.cmd.FusekiCmd`, and update some argument accordingly.
- The Fuseki configuration file should be mounted at `/fuseki/configuration/config.ttl` instead of `/fuseki/config.ttl`.

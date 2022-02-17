{
  description = "Static-asset project dependencies and utilities.";

  inputs = {
    project-lib.url = "path:./lib/projects/lib";
  };

  outputs = { self, project-lib, ... }:
    {
      lib = {
        id = "static";
        defineProject = config: project-lib.lib.defineProject config;
      };
    };

}

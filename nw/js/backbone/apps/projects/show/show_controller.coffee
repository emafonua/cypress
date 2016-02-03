@App.module "ProjectsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Application

    initialize: (params) ->
      {project, options} = params

      projectView = @getProjectView(project)

      @listenTo projectView, "client:url:clicked", ->
        App.execute "gui:external:open", project.get("clientUrl")

      @listenTo projectView, "stop:clicked ok:clicked" , ->
        App.config.closeProject().then ->
          App.vent.trigger "start:projects:app"

      @show projectView

      _.defaults options,
        onError: ->
        onProjectStart: ->
        onReboot: =>
          project.reset()

          App.config.closeProject().then =>
            @runProject(project, options)

      _.defer => @runProject(project, options)

    runProject: (project, options) ->
      App.config.runProject(project.get("path"), options)
        .then (config) ->
          project.setClientUrl(config.clientUrl, config.clientUrlDisplay)

          App.execute("start:id:generator", config.idGeneratorUrl) if config.idGenerator

          options.onProjectStart(config)

        .catch (err) ->
          project.setError(err)
          options.onError(err)

    getProjectView: (project) ->
      new Show.Project
        model: project
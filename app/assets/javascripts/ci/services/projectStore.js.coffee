CI.service 'projectStore',
  ($http, $q,  eventSource, cacheStore) ->

    cache    = cacheStore()
    projects = cache.collection("projects")

    subscribe = (e) ->
      switch e.action
        when 'created'
          projects.addItem e.data
        when 'updated'
          cache.item(e.id).update e.data, 'projects'
        when 'destroyed'
          cache.item(e.id).remove 'projects'

    eventSource.subscribe "events.projects", subscribe

    all = () ->
      projects.get () ->
        $http.get("/api/projects").then (re) ->
          re.data

    one = (id) ->
      id = parseInt(id)
      all().then (its) ->
        _.find its, (it) ->
          it.id == id

    all: all
    one: one

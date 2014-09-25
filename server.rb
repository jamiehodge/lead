require_relative "lib/lead"

module Lead
  10.times { Article.create(title: "xyzzy", body: "body") }

  controller = Controller.new(model: Article)

  collection = %r(/)
  item = %r(/(?<id>\d+))

  routes = [
    { method: "get", path: collection, controller: controller, action: :list},
    { method: "post", path: collection, controller: controller, action: :create},
    { method: "get", path: item, controller: controller, action: :create},
    { method: "put", path: item, controller: controller, action: :update},
    { method: "delete", path: item, controller: controller, action: :delete}
  ]

  router = Router.new(routes: routes)

  Server.new(router: router).listen
end

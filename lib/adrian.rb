require 'adrian/version'

module Adrian
  autoload :ArrayQueue,           'adrian/array_queue'
  autoload :CompositeQueue,       'adrian/composite_queue'

  autoload :Dispatcher,           'adrian/dispatcher'
  autoload :GirlFridayDispatcher, 'adrian/girl_friday_dispatcher'

  autoload :Worker,               'adrian/worker'
end

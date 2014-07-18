define ['./ObservableObject'], (ObservableObject) ->
	class Relationship extends ObservableObject
		observeObject: (object, observer) ->
			object.observe (_observer=(mutation) =>
				if @_instance.model.manager.relationshipsPaused
					@_instance.model.manager.mutations.push observer:observer, mutation:mutation
				else
					observer mutation
			), @
			@observedObjects ?= []
			@observedObjects.push object:object, observer:_observer
			
		stopObservingObjects: ->
			if @observedObjects
				object.stopObserving observer for {observer:observer, object:object} in @observedObjects
				delete @observedObjects

		destruct: ->
			@stopObservingObjects()
			@onDestruct?()
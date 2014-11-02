package stateMachine
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertTrue;
	import org.mockito.integrations.any;
	import org.mockito.integrations.anyOf;
	import org.mockito.integrations.eq;
	import org.mockito.integrations.given;
	import org.mockito.integrations.never;
	import org.mockito.integrations.verify;
	import org.mockito.integrations.flexunit4.MockitoRule;
	
	import stateMachine.event.TransitionCompleteEvent;
	import stateMachine.event.TransitionDeniedEvent;
	import stateMachine.param.ExitStateParams;
	
	import utils.DelegateAnswerTo;
	import utils.EventDispatcherEventCollector;
	
	public class StateMachineTest
	{	
		[Rule]
		public var mockito:MockitoRule = new MockitoRule();
		
		//----------------------------------
		//  Mocks
		//----------------------------------
		[Mock]
		public var mockState:IState;
		
		[Mock]
		public var mockEventDispatcher:IEventDispatcher;
		
		//----------------------------------
		//  vars
		//----------------------------------
		private var _instance:StateMachine;
		
		//--------------------------------------------------------------------------
		//
		//  SETUP
		//
		//--------------------------------------------------------------------------
		[Before]
		public function setUp():void {
			_instance = new StateMachine();
			_instance.init();
		}
		
		[After]
		public function tearDown():void {
			_instance.destroy();
			_instance = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  TESTS
		//
		//--------------------------------------------------------------------------
		[Test]
		public function test_UNINITIAL_STATE_IsExpectedValue():void {
			var expected:String = "uninitializedState";
			
			assertEquals(expected, StateMachine.UNINITIALIZED_STATE);
		}
		
		[Test]
		public function testStateShouldBeInitializedTo_NO_STATE():void {
			var expected:String = StateMachine.UNINITIALIZED_STATE;
			
			assertEquals(expected, _instance.state);
		}
		
		[Test]
		public function testInitialStateShouldNoChangeForUnknownState():void {
			var expected:String = StateMachine.UNINITIALIZED_STATE;
			var unknownState:String = "foo";
			
			_instance.initialState = unknownState;
			
			assertEquals(expected, _instance.state);
		}
		
		[Test]
		public function testAddStateShouldNotChangeCurrentState():void {
			var expected:String = StateMachine.UNINITIALIZED_STATE;
			
			_instance.addState(createPlayingState());
			
			assertEquals(expected, _instance.state);
		}
		
		[Test]
		public function testHasStateByNameShouldReturnFalseForUnknownState():void {
			var unknownStateName:String = "foo";
			
			var result:Boolean = _instance.hasStateByName(unknownStateName);
			
			assertFalse("expecting hasStateByName to return false for unknown state", result);
		}
		
		[Test]
		public function testHasStateByNameShouldReturnTrueForKnownState():void {
			var knownState:IState = createPlayingState();
			var expectedKnownStateName:String = knownState.name;
			_instance.addState(createPlayingState());
			
			var result:Boolean = _instance.hasStateByName(expectedKnownStateName);
			
			assertTrue("expecting hasStateByName to return true for known state", result);
		}
		
		[Test]
		public function testAddStateShouldTakeIStateArgument():void {
			var knownState:IState = mockState;
			
			_instance.addState(createPlayingState());
		}
		
		[Test]
		public function testAddStateShouldBeCallableMultipleTimes():void {
			_instance.addState(createPlayingState());
			_instance.addState(createPausedState());
			_instance.addState(createStoppedState());
		}
		
		[Test]
		public function testInitialStateShouldNotBeNull():void {
			assertNotNull(_instance.state);
		}
		
		[Test]
		public function testInitialStateShouldBeSetableToKnownState():void {
			var initialState:IState = createStoppedState();
			var expectedInitialStateName:String = initialState.name;
			_instance.addState(initialState);
			
			_instance.initialState = expectedInitialStateName;
			
			assertEquals(expectedInitialStateName, _instance.state);			
		}
		
		[Test]
		public function testInitialStateShouldCallEnterCallbackOfNewState():void {
			var initialState:IState = createStoppedState();
			_instance.addState(initialState);
			
			_instance.initialState = initialState.name;
			
			verify().that(mockStoppedEnterHandler.enter(any(), any(), any()));
		}
		
		[Test]
		public function testInitialStateShouldCallEnterCallbackWithExpectedArguments():void {
			var initialState:IState = createStoppedState();
			_instance.addState(initialState);
			
			_instance.initialState = initialState.name;
			
			verify()
				.that(mockStoppedEnterHandler.enter(eq(initialState.name), any(), any()));
		}
		
		[Test]
		public function testInitialStateShouldNotifyThatTheTransitionCompleted():void {
			var collector:EventDispatcherEventCollector = setupEventCollector();
			
			var initialState:IState = createStoppedState();
			_instance.addState(initialState);
			
			_instance.initialState = initialState.name;
			
			assertEquals(1, collector.timesDispatched);
			assertTrue("expecting TransitionCompleteEvent event", collector.events[0] as TransitionCompleteEvent);
			assertEquals(TransitionCompleteEvent.TRANSITION_COMPLETE, TransitionCompleteEvent(collector.events[0]).type);
			assertEquals(initialState.name, TransitionCompleteEvent(collector.events[0]).toState);
		}
		
		[Test]
		public function testInitialStateShouldUseNullPatternWhenCallingEnterCallbackOfNewState():void {
			var initialState:IState = createNullPatternTestState();
			_instance.addState(initialState);
			
			_instance.initialState = initialState.name;
			
			// test should not error
		}
		
		[Test]
		public function testShouldWrapIEventDispatcher():void {
			_instance.setDispatcher(mockEventDispatcher);
			var listener:Function = function(event:Event):void {
			};
			
			_instance.addEventListener("expected", listener, true, -1, true);
			verify().that(mockEventDispatcher.addEventListener(eq("expected"), eq(listener), eq(true), eq(-1), eq(true)));
			
			_instance.removeEventListener("expected", listener, true);
			verify().that(mockEventDispatcher.removeEventListener(eq("expected"), eq(listener), eq(true)));
			
			var event:Event = new Event("expected");
			_instance.dispatchEvent(event);
			verify().that(mockEventDispatcher.dispatchEvent(eq(event)));
			
			_instance.hasEventListener("expected");
			verify().that(mockEventDispatcher.hasEventListener(eq("expected")));
			
			_instance.willTrigger("expected");
			verify().that(mockEventDispatcher.willTrigger(eq("expected")));
		}
		
		[Test]
		public function testGetStateByNameShouldUseNullPattern():void {
			var unknownStateName:String = "foo";
			
			var result:IState = _instance.getStateByName(unknownStateName);
			
			assertNotNull(result);
			assertEquals(StateMachine.UNKNOWN_STATE, result);
		}
		
		[Test]
		public function testGetStateByNameShouldReturnKnownState():void {
			var state:IState = createStoppedState();
			_instance.addState(state);
			var knownStateName:String = state.name;
			
			var result:IState = _instance.getStateByName(knownStateName);
			
			assertEquals(state, result);
		}
		
		[Test]
		public function testCanChangeStateToShouldReturnFalseForUnknownState():void {
			var unknownStateName:String = "foo";
			
			var result:Boolean = _instance.canChangeStateTo(unknownStateName);
			
			assertFalse(result);
		}
		
		[Test]
		public function testCanChangeStateToShouldReturnFalseForSameState():void {
			var initialState:IState = createPausedState();
			_instance.addState(initialState);
			_instance.initialState = initialState.name;
			var sameStateName:String = initialState.name; 
			
			var result:Boolean = _instance.canChangeStateTo(sameStateName);
			
			assertFalse(result);
		}
		
		[Test]
		public function testCanChangeStateToShouldTrueWhenNewStatesFromIsWildcard():void {
			var initialState:IState = createStoppedState();
			_instance.addState(initialState);
			_instance.initialState = initialState.name;
			var nextState:IState = createFromWildCardState();
			_instance.addState(nextState);
			
			var result:Boolean = _instance.canChangeStateTo(nextState.name);
			
			assertTrue(result);
		}
		
		[Test]
		public function testCanChangeStateToShouldTrueWhenNewStatesFromIncludeCurrentState():void {
			var initialState:IState = createStoppedState();
			_instance.addState(initialState);
			_instance.initialState = initialState.name;
			var nextState:IState = createPlayingState();
			_instance.addState(nextState);
			
			var result:Boolean = _instance.canChangeStateTo(nextState.name);
			
			assertTrue(result);
		}
		
		[Test]
		public function testCanChangeStateToShouldTrueWhenParentStateIncludesDestinationState():void {
			setupQuakeStateExample();
			
			var result:Boolean = _instance.canChangeStateTo("smash");
			
			assertTrue(result);
		}
		
		[Test]
		public function testfindPathShouldForBothUnknownStates():void {
			var unknownStartName:String = "foo";
			var unknownEndName:String = "bar";
			
			var result:Array = _instance.findPath(unknownStartName, unknownEndName);
			
			assertNotNull(result);
			assertEquals(2, result.length);
			assertEquals("expected froms incorrect", 0, result[0]);
			assertEquals("expected tos incorrect", 0, result[1]);
		}
		
		[Test]
		public function testfindPathShouldReturnZeroWhenStartUnknown():void {
			var unknownStartName:String = "foo";
			var endState:IState = createFromWildCardState();
			var knowEndName:String = endState.name;
			_instance.addState(endState);
			
			var result:Array = _instance.findPath(unknownStartName, knowEndName);
			
			assertNotNull(result);
			assertEquals(2, result.length);
			assertEquals("expected froms incorrect", 0, result[0]);
			assertEquals("expected tos incorrect", 0, result[1]);
		}
		
		[Test]
		public function testfindPathShouldReturnZeroWhenEndUnknown():void {
			var startState:IState = createFromWildCardState();
			var knowStartName:String = startState.name;
			_instance.addState(startState);
			var unknownEndName:String = "foo";
			
			var result:Array = _instance.findPath(knowStartName, unknownEndName);
			
			assertNotNull(result);
			assertEquals(2, result.length);
			assertEquals("expected froms incorrect", 0, result[0]);
			assertEquals("expected tos incorrect", 0, result[1]);
		}
		
		[Test]
		public function testfindPathShouldReturnExpectedForOneToOnePath():void {
			var startState:IState = createStoppedState();
			var startStateName:String = startState.name;
			_instance.addState(startState);
			var endState:IState = createPlayingState();
			var endStateName:String = endState.name;
			_instance.addState(endState);
			
			var result:Array = _instance.findPath(startStateName, endStateName);
			
			assertNotNull(result);
			assertEquals(2, result.length);
			assertEquals("expected froms incorrect", 1, result[0]);
			assertEquals("expected tos incorrect", 1, result[1]);
		}
		
		[Test]
		public function testFindPathShouldReturnExpectedForLongPath():void {
			setupQuakeStateExample();
			
			var result:Array = _instance.findPath("idle", "punch");
			
			assertNotNull(result);
			assertEquals(2, result.length);
			assertEquals("expected froms incorrect", 1, result[0]);
			assertEquals("expected tos incorrect", 3, result[1]);
		}
		
		[Test]
		public function testFindPathShouldReturnExpectedForLongPathReversed():void {
			setupQuakeStateExample();
			
			var result:Array = _instance.findPath("punch", "idle");
			
			assertNotNull(result);
			assertEquals(2, result.length);
			assertEquals("expected froms incorrect", 3, result[0]);
			assertEquals("expected tos incorrect", 1, result[1]);
		}
		
		[Test]
		public function testChangeStateShouldDoNothingForUnknownState():void {
			var initialState:IState = createStoppedState();
			_instance.addState(initialState);
			_instance.initialState = initialState.name;
			var unknowStateName:String = "foo";
			
			_instance.changeState(unknowStateName);
			
			assertEquals(initialState.name, _instance.state);
		}
		
		[Test]
		public function testChangeStateShouldDoNothingForIllegalStateTransition():void {
			var initialState:IState = createStoppedState();
			_instance.addState(initialState);
			_instance.initialState = initialState.name;
			var illegalState:IState = createPausedState();
			_instance.addState(illegalState);
			var illegalStateName:String = illegalState.name;
			
			_instance.changeState(illegalStateName);
			
			assertEquals(initialState.name, _instance.state);
		}
		
		[Test]
		public function testChangeStateShouldNotifyTransitionDeniedForIllegalStateTransition():void {
			_instance.setDispatcher(mockEventDispatcher);
			var initialState:IState = createStoppedState();
			_instance.addState(initialState);
			_instance.initialState = initialState.name;
			var illegalState:IState = createPausedState();
			_instance.addState(illegalState);
			var illegalStateName:String = illegalState.name;
			// start listening to events after the setup
			var collector:EventDispatcherEventCollector = new EventDispatcherEventCollector(mockEventDispatcher);
			
			_instance.changeState(illegalStateName);
			
			assertEquals(1, collector.timesDispatched);
			assertTrue("expecting TransitionDeniedEvent", collector.events[0] as TransitionDeniedEvent);
			assertEquals(initialState.name, TransitionDeniedEvent(collector.events[0]).fromState);
			assertEquals(illegalState.name, TransitionDeniedEvent(collector.events[0]).toState);
			assertEquals(illegalState.from, TransitionDeniedEvent(collector.events[0]).allowedStates);
		}
		
		[Test]
		public function testChangeStateShouldCallFromStatesExitHandler():void {
			var initialState:IState = createFirstState();
			_instance.addState(initialState);
			_instance.initialState = initialState.name;
			var nextState:IState = createSecondState();
			_instance.addState(nextState);
			var nextStateName:String = nextState.name;
			
			_instance.changeState(nextStateName);
			
			verify().that(mockFirstStateExitHandler.exit(anyOf(ExitStateParams)));
		}
		
		[Test]
		public function testChangeStateShouldCallFromStatesExitHandlerWithExpectedPayload():void {
			var initialState:IState = createFirstState();
			_instance.addState(initialState);
			_instance.initialState = initialState.name;
			var nextState:IState = createSecondState();
			_instance.addState(nextState);
			var nextStateName:String = nextState.name;
			var receivedEvent:ExitStateParams;
			var callback:Function = function(event:ExitStateParams):void {
				receivedEvent = event;
			};
			given(mockFirstStateExitHandler.exit(any()))
				.will(new DelegateAnswerTo(callback));
			
			_instance.changeState(nextStateName);
		
			assertNotNull(receivedEvent);
			assertEquals(ExitStateParams.EXIT_CALLBACK, receivedEvent.type);
			assertEquals(initialState.name, receivedEvent.fromState);
			assertEquals(nextState.name, receivedEvent.toState);
			assertEquals(initialState.name, receivedEvent.currentState);
		}
				 
		[Test]
		public function testGetParentByNameShouldReturnUnknownStateIfNotKnown():void {
			var unknownStateName:String = "foo";
			
			var result:IState = _instance.getParentStateByName(unknownStateName);
			
			assertNotNull("expecting Null Pattern", result);
			assertEquals(StateMachine.UNKNOWN_STATE, result);
		}
		
		[Test]
		public function testGetParentByNameShouldReturnUnknownParentStateIfParentNotKnown():void {
			var knownChildState:IState = createChildState();
			_instance.addState(knownChildState);
			var knownChildStateName:String = knownChildState.name;
			
			var result:IState = _instance.getParentStateByName(knownChildStateName);
			
			assertNotNull("expecting Null Pattern", result);
			assertEquals(StateMachine.UNKNOWN_PARENT_STATE, result);
		}
		
		[Test]
		public function testGetParentByNameShouldReturnParentStateOfChildState():void {
			var childState:IState = createChildState();
			_instance.addState(childState);
			var knownChildStateName:String = childState.name;
			var expectedParentState:IState = createParentState();
			_instance.addState(expectedParentState);
			
			var result:IState = _instance.getParentStateByName(knownChildStateName);
			
			assertNotNull("expecting Null Pattern", result);
			assertEquals(expectedParentState, result);
		}
		
		[Test]
		public function testGetParentByNameShouldReturnNoParentStateForChildWithNoParent():void {
			var stateWithNoParent:IState = createFirstState();
			_instance.addState(stateWithNoParent);
			var stateWithNoParentName:String = stateWithNoParent.name;
			
			var result:IState = _instance.getParentStateByName(stateWithNoParentName);
			
			assertNotNull("expecting Null Pattern", result);
			assertEquals(StateMachine.NO_PARENT_STATE, result);
		}
		
		[Test]
		public function testChangeStateShouldBeAbleToNavigateToAChildState():void {
			setupQuakeStateExample();
			
			assertEquals("not expected initial state", "idle", _instance.state);
			_instance.changeState("smash");
			assertEquals("not expected state after smash", "smash", _instance.state);
			_instance.changeState("idle");
			assertEquals("not expected state after return to idle", "idle", _instance.state);
		}
		
		[Test]
		public function testChangeStateShouldBeAbleToNavigateToStateAndCallAllParentStateEnterCallbacks():void {
			setupQuakeStateExample();
			
			assertEquals("not expected initial state", "idle", _instance.state);
			_instance.changeState("smash");
			
			verify().that(mockOnAttack.enter(eq("smash"), eq("idle"), eq("attack")));
			verify().that(mockOnMeleeAttack.enter(eq("smash"), eq("idle"), eq("melee attack")));
			verify().that(mockOnSmash.enter(eq("smash"), eq("idle"), eq("smash")));
			
			_instance.changeState("idle");
			assertEquals("not expected state after return to idle", "idle", _instance.state);
		}
		
		[Test]
		public function testChangeStateShouldCallExitStatesForParentsStates():void {
			setupQuakeStateExample();
			
			_instance.changeState("smash");
			verify(never()).that(mockOnExitMeleeAttack.exit(any()));
			_instance.changeState("idle");
			verify().that(mockOnExitMeleeAttack.exit(any()));
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------
		[Mock]
		public var mockPlayStateEnterHandler:IEnter;
		
		[Mock]
		public var mockPlayStateExitHandler:IExit;
		
		private function createPlayingState():IState {
			var state:State = new State("playing", {
				enter: mockPlayStateEnterHandler,
				exit: mockPlayStateExitHandler,
				from: ["paused","stopped"]
			});
			return state;
		}
		
		[Mock]
		public var mockPauseEnterHandler:IEnter;
		
		private function createPausedState():IState {
			var state:State = new State("paused", {
				enter: mockPauseEnterHandler,
				from: "playing"
			});
			return state;
		}
		
		[Mock]
		public var mockStoppedEnterHandler:IEnter;
		
		private function createStoppedState():IState {
			var state:State = new State("stopped", {
				enter: mockStoppedEnterHandler,
				from: "*"
			});
			return state;
		}
		
		[Mock]
		public var mockFirstStateEnterHandler:IEnter;
		
		[Mock]
		public var mockFirstStateExitHandler:IExit;
		
		private function createFirstState():IState {
			var state:State = new State("first", {
				enter: mockFirstStateEnterHandler,
				exit: mockFirstStateExitHandler,
				from: ["second"]
			});
			return state;
		}
		
		[Mock]
		public var mockSecondStateEnterHandler:IEnter;
		
		[Mock]
		public var mockSecondStateExitHandler:IExit;
		
		private function createSecondState():IState {
			var state:State = new State("second", {
				enter: mockSecondStateEnterHandler,
				exit: mockSecondStateExitHandler,
				from: ["first"]
			});
			return state;
		}
		
		[Mock]
		public var mockParentOnEnter:IEnter;
		
		[Mock]
		public var mockParentOnExit:IExit;
		
		private function createParentState():IState {
			var state:State = new State("parent", {
				enter: mockParentOnEnter,
				exit: mockParentOnExit
			});
			return state;
		}
		
		[Mock]
		public var mockChildOnEnter:IEnter;
		
		[Mock]
		public var mockChildOnExit:IExit;
		
		private function createChildState():IState {
			var state:State = new State("child", {
				parent: "parent",
				enter: mockChildOnEnter,
				exit: mockChildOnExit,
				from: ["first"]
			});
			return state;
		}
		
		[Mock]
		public var mockGrandChildOnEnter:IEnter;
		
		[Mock]
		public var mockGrandChildOnExit:IExit;
		
		private function createGrandChildState():IState {
			var state:State = new State("grandChild", {
				parent: "child",
				enter: mockGrandChildOnEnter,
				exit: mockGrandChildOnExit,
				from: ["first"]
			});
			return state;
		}
		
		[Mock]
		public var mockOnIdle:IEnter;
		
		[Mock]
		public var mockOnAttack:IEnter;
		
		[Mock]
		public var mockOnMeleeAttack:IEnter;
		
		[Mock]
		public var mockOnExitMeleeAttack:IExit;
		
		[Mock]
		public var mockOnSmash:IEnter;
		
		[Mock]
		public var mockOnPunch:IEnter;
		
		[Mock]
		public var mockOnMissle:IEnter;
		
		[Mock]
		public var mockOnDead:IEnter;
		
		[Mock]
		public var mockOnDie:IExit;
		
		/**
		 * It's also possible to create hierarchical state machines using the argument "parent" in the addState method
		 * This example shows the creation of a hierarchical state machine for the monster of a game
		 * (Its a simplified version of the state machine used to control the AI in the original Quake game)
		 **/
		private function setupQuakeStateExample():void {
			_instance.addState(new State("idle", {enter: mockOnIdle, from:"attack"}));
			_instance.addState(new State("attack", {enter: mockOnAttack, from:"idle"}));
			_instance.addState(new State("melee attack", {parent:"attack", enter: mockOnMeleeAttack, exit: mockOnExitMeleeAttack, from:"attack"}));
			_instance.addState(new State("smash", {parent:"melee attack", enter: mockOnSmash}));
			_instance.addState(new State("punch", {parent:"melee attack", enter: mockOnPunch}));
			_instance.addState(new State("missle attack", {parent:"attack", enter: mockOnMissle}));
			_instance.addState(new State("die", {enter:mockOnDead, from:"attack", exit:mockOnDie}));
			
			_instance.initialState = "idle"
		}
		
		private function createNullPatternTestState():IState {
			var state:State = new State("nullPatternTest", {});
			return state;
		}
		
		private function createFromWildCardState():IState {
			var state:State = new State("fromWildCardTest", {
				from: State.WILDCARD
			});
			return state;
		}
		
		private function setupEventCollector():EventDispatcherEventCollector {
			given(mockEventDispatcher.hasEventListener(any())).willReturn(true);
			_instance.setDispatcher(mockEventDispatcher);
			return new EventDispatcherEventCollector(mockEventDispatcher);
		}
	}
}
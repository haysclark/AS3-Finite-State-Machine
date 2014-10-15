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
	import org.mockito.integrations.verify;
	import org.mockito.integrations.flexunit4.MockitoRule;
	
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
		public var mockPlayStateEnterHandler:IEnter;
		
		[Mock]
		public var mockPlayStateExitHandler:IExit;
		
		[Mock]
		public var mockPauseEnterHandler:IEnter;
		
		[Mock]
		public var mockStoppedEnterHandler:IEnter;
		
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
			
			//_instance.addState(createPlayingState());
			//_instance.addState(createPausedState());
			//_instance.addState(createStoppedState());
			
			//_instance.addEventListener(StateMachineEvent.TRANSITION_DENIED, transitionDeniedFunction);
			//_instance.addEventListener(StateMachineEvent.TRANSITION_COMPLETE, transitionCompleteFunction);
			
			//_instance.initialState = "stopped";
		}
		
		[After]
		public function tearDown():void {
			_instance = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  TESTS
		//
		//--------------------------------------------------------------------------
		[Test]
		public function testConstNO_STATEIsExpectedValue():void {
			var expected:String = "no state";
			
			assertEquals(expected, StateMachine.NO_STATE);
		}
		
		[Test]
		public function testStateShouldBeInitializedTo_NO_STATE():void {
			var expected:String = StateMachine.NO_STATE;
			
			assertEquals(expected, _instance.state);
		}
		
		[Test]
		public function testInitialStateShouldNoChangeForUnknownState():void {
			var expected:String = StateMachine.NO_STATE;
			var unknownState:String = "foo";
			
			_instance.initialState = unknownState;
			
			assertEquals(expected, _instance.state);
		}
		
		[Test]
		public function testAddStateShouldNotChangeCurrentState():void {
			var expected:String = StateMachine.NO_STATE;
			
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
			
			verify().that(mockStoppedEnterHandler.enter(anyOf(StateMachineEvent)));
		}
		
		[Test]
		public function testInitialStateShouldCallEnterCallbackWithExpectedEvent():void {
			var receivedEvent:StateMachineEvent;
			var callback:Function = function(event:StateMachineEvent):void {
				receivedEvent = event;
			};
			given(mockStoppedEnterHandler.enter(any()))
				.will(new DelegateAnswerTo(callback));
			var initialState:IState = createStoppedState();
			_instance.addState(initialState);
			
			_instance.initialState = initialState.name;
			
			assertNotNull(receivedEvent);
			assertEquals(StateMachineEvent.ENTER_CALLBACK, receivedEvent.type);
			assertEquals(initialState.name, receivedEvent.toState);
		}
		
		[Test]
		public function testInitialStateShouldNotifyThatTheTransitionCompleted():void {
			var collector:EventDispatcherEventCollector = setupEventCollector();
			
			var initialState:IState = createStoppedState();
			_instance.addState(initialState);
			
			_instance.initialState = initialState.name;
			
			assertEquals(1, collector.timesDispatched);
			assertTrue("expecting StateMachineEvent event", collector.events[0] as StateMachineEvent);
			assertEquals(StateMachineEvent.TRANSITION_COMPLETE, StateMachineEvent(collector.events[0]).type);
			assertEquals(initialState.name, StateMachineEvent(collector.events[0]).toState);
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
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------
		private function createPlayingState():IState {
			var state:State = new State("playing", {
				enter: mockPlayStateEnterHandler,
				exit: mockPlayStateExitHandler,
				from: ["paused","stopped"]
			});
			return state;
		}
		
		private function createPausedState():IState {
			var state:State = new State("paused", {
				enter: mockPauseEnterHandler,
				from: "playing"
			});
			return state;
		}
		
		private function createStoppedState():IState {
			var state:State = new State("stopped", {
				enter: mockStoppedEnterHandler,
				from: "*"
			});
			return state;
		}
		
		private function createNullPatternTestState():IState {
			var state:State = new State("nullPatternTest", {});
			return state;
		}
		
		private function setupEventCollector():EventDispatcherEventCollector {
			given(mockEventDispatcher.hasEventListener(any())).willReturn(true);
			_instance.setDispatcher(mockEventDispatcher);
			return new EventDispatcherEventCollector(mockEventDispatcher);
		}
	}
}
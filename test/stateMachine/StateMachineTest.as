package stateMachine
{
	import org.mockito.integrations.flexunit4.MockitoRule;
	
	public class StateMachineTest
	{	
		[Rule]
		public var mockito:MockitoRule = new MockitoRule();
		
		//----------------------------------
		//  Mocks
		//----------------------------------
		[Mock]
		public var mockPlayStateEnterHandler:IEnter;
		
		[Mock]
		public var mockPlayStateExitHandler:IExit;
		
		[Mock]
		public var mockPauseEnterHandler:IEnter;
		
		[Mock]
		public var mockStoppedEnterHandler:IEnter;
		
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
		public function testShould():void {
			
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
		
		//_instance.addState("stopped",{ enter: onStoppedEnter, from:"*"});
		private function createStoppedState():IState {
			var state:State = new State("stopped", {
				enter: mockStoppedEnterHandler,
				from: "*"
			});
			return state;
		}
	}
}
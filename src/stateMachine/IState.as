package stateMachine
{
	public interface IState
	{
		function get name():String;
		function get from():Array;
		
		//function allowTransitionFrom(stateName:String):Boolean;
		
		function get enter():IEnter;
		function get exit():IExit;
		
		function get parentName():String;
		
		//function init(stateMachine:StateMachine):void;
		//function get parent():IState;
		//function set parent(parent:IState):void;
		//function get parents():Array;
		//function get children():Array;
		//function set children(children:Array):void;
		
		/**
		 * The root of a state is it's top level parent, if no parents then
		 * the state 'root' is itself.
		 */
		//function get root():IState;
		
		function toString():String;
	}
}
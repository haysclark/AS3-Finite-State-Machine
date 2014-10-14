package stateMachine
{
	public interface IState
	{
		function init(stateMachine:StateMachine):void
		
		function allowTransitionFrom(stateName:String):Boolean
		
		function get name():String
		function get from():Object
		
		function get enter():IEnter
		function get exit():IExit
		
		function get parent():IState
		function set parent(parent:IState):void
		function get parentName():String
		function get parents():Array
		function get children():Array
		function set children(children:Array):void
		function get root():IState
		
		function toString():String
	}
}
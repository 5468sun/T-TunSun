package sxf.utils.gamedrawing{
	
	public class GameDrawing{
		
		static public const CLOCK_WISE:String = "clockWise";
		static public const COUNTER_CLOCK_WISE:String = "counterClockWise";
		
		static public function drawClockWise(teams:Array):Array{
			
			var result:Array;
			var newTeams:Array = chkTeams(teams);
			
			if(newTeams.length == 0){
			
				result = newTeams;
			
			}else{
			
				var rawResult:Array = arrangeTeams(newTeams);
				result = formatTeams(rawResult);
			
			}
			
			return result;
		}
		
		static private function chkTeams(teams:Array):Array{
			
			if(teams.length%2 != 0){
				
				teams.push("轮空");
				
			}
			
			return teams;
			
		}
		
		static private function arrangeTeams(teams:Array):Array{
		
			var result:Array = [];
			
			var len:int = teams.length;
			
			result.push(copyTeams(teams));
			
			for(var i:int=1; i<len-1; i++){
			
				reorderTeams(teams,CLOCK_WISE);
				result.push(copyTeams(teams));
			
			}
			
			return result; 
		
		}
		
		static private function reorderTeams(teams:Array,type:String):void{
			
			var team:Object;
			
			switch(type){
			
				case CLOCK_WISE:
					
					team = teams.pop();
					teams.splice(1,0,team);
					break;
				
				case COUNTER_CLOCK_WISE:
					
					team = teams.splice(1,1)[0];
					teams.push(team);
					break;
					
				default:
					
					team = teams.splice(1,1)[0];
					teams.push(team);
					break;
			
			}
			
		
		}
		
		static private function copyTeams(teams:Array):Array{
		
			var newTeams:Array = new Array();
			
			for each(var i:Object in teams){
			
				newTeams.push(i);
			
			}
			
			return newTeams;
		
		}
		
		static private function formatTeams(teams:Array):Array{
		
			var result:Array = new Array;
			
			for each (var g:Array in teams){
			
				var group:Array = new Array();
				
				for (var i:int=0; i<g.length/2; i++){
				
					var match:Array = new Array();
					match.push(g[i]);
					match.push(g[g.length-i-1]);
					group.push(match);

				}
				
				result.push(group);
			
			}
			
			return result;
		
		}
		
		public function GameDrawing(singletonEnforcer:SingletonEnforcer){}
		
		
	}
}

class SingletonEnforcer{}
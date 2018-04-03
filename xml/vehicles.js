var speedsList = [1000, 80, 120, 180, 250, 300]
var accelerationsList = [0, 60, 35, 25, 17, 15]
var inertiasList = [5, 150, 160, 180, 210, 250]


var a = document.getElementById("myxml");
var len = list.length;

var vehicles=document.createElement("vehicles");
a.appendChild(vehicles)
for(var i = 0; i<len; i+=4){
	var v = document.createElement("vehicle")
	v.setAttribute("id",parseInt(list[i]));
	v.setAttribute("name",list[i+1]);
	v.setAttribute("type",list[i+3]);
	v.setAttribute("soundName","i4slow.ogg");
	v.setAttribute("revLimit",6000);
	v.setAttribute("soundBase",3500);
	v.setAttribute("soundVolume",0.15);
	v.setAttribute("numberGears",5);
	v.setAttribute("hasTurbo",0);
	v.setAttribute("hasBackfire",0);
	v.setAttribute("turboBoostFactor",0);
	v.setAttribute("exhaustNumber",1);
	var speeds=document.createElement("speeds");
	var accelerations=document.createElement("accelerations");
	var inertias=document.createElement("inertias");
	for(var j = 0; j<6; j++){
		var speed=document.createElement("speed");
		speed.setAttribute("gear",j);
		speed.setAttribute("value",speedsList[j]);
		speeds.appendChild(speed);
	}
	for(var j = 0; j<6; j++){
		var acceleration=document.createElement("acceleration");
		acceleration.setAttribute("gear",j);
		acceleration.setAttribute("value",accelerationsList[j]);
		accelerations.appendChild(acceleration);
	}
	for(var j = 0; j<6; j++){
		var inertia=document.createElement("inertia");
		inertia.setAttribute("gear",j);
		inertia.setAttribute("value",inertiasList[j]);
		inertias.appendChild(inertia);
	}
	v.appendChild(speeds);
	v.appendChild(accelerations);
	v.appendChild(inertias);
	vehicles.appendChild(v);
	
}
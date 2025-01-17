package;

import haxe.Json;
import flixel.util.FlxSave;
import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import flixel.sound.FlxSound;
import flixel.addons.display.FlxRuntimeShader;
import flixel.util.FlxColor;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard',
		'png'
	];
	public static var defaultDifficulty:String = 'Normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}
	
	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if(fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if(FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
		#else
		if(Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}
	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	//uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void {
		Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void {
		Paths.music(sound, library);
	}

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function showPopUp(message:String, title:String):Void
	{
		/*
		#if android
		android.Tools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		#else
                */
		FlxG.stage.window.alert(message, title);
		//#end
	}

	/** Quick Function to Fix Save Files for Flixel 5
		if you are making a mod, you are gonna wanna change "ShadowMario" to something else
		so Base Psych saves won't conflict with yours
		@BeastlyGabi
	**/
	public static function getSavePath(folder:String = 'ShadowMario'):String {
		@:privateAccess
		return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}

	public static function fragToString(frag:String = '', library:String = ''):String {
		var path:Dynamic;
		if (library != '')
			path = Paths.shaderFragment(frag,library);
		else 
			path = Paths.shaderFragment(frag);

		if(FileSystem.exists(path)) {
			path = File.getContent(path);
		}
		return path;
	}

	public static function initializeShader(shader:String,?updateiTime:Bool = false):FlxRuntimeShader 
	{
		if (!ClientPrefs.shaders) return new FlxRuntimeShader(); 
		else {
			var fragment = CoolUtil.fragToString(shader);
			if (fragment.contains('assets/shaders')) {
				trace('invalid shader Fragment! "$fragment"');
				FlxG.log.error('invalid shader Fragment! "$fragment"');
				return new FlxRuntimeShader();
			}
			else {
				var newShader = new FlxRuntimeShader(CoolUtil.fragToString(shader));
				if (updateiTime) newShader.updateiTime = true;
				return newShader;
			}
		}
	}

	public static function mouseOverlaps(object:flixel.FlxSprite, camera:flixel.FlxCamera):Bool 
	{
		var mouseX = FlxG.mouse.getPositionInCameraView(camera).x;
        var mouseY = FlxG.mouse.getPositionInCameraView(camera).y;
		if (mouseY >= object.y && mouseY <= (object.y + object.height) && mouseX >= object.x && mouseX <= (object.x+object.width)) 
			return true;
		else return false;
	}



	public static function CreateCredits(song:String):String
	{

		//"love you" - floombo


		if (FileSystem.exists('assets/data/' + Paths.formatToSongPath(song) + '/credits.json') || FileSystem.exists('mods/data/' + Paths.formatToSongPath(song) + '/credits.json')) {
			var creditpeople = haxe.Json.parse(Paths.getTextFromFile('data/' + Paths.formatToSongPath(song) + '/credits.json'));
			var music:Array<String> = creditpeople.music;
			var arter:Array<String> = creditpeople.arter;
			var coder:Array<String> = creditpeople.coder;
			var charters:Array<String> = creditpeople.charter;
			var people = '@$song@';
			if (music != null) for (i in music) people += '\n^^$i^^';
			people += '\n\n@Art@';
			if (arter != null) for (i in arter) people += '\n^^$i^^';
			people += '\n\n@Coding@';
			if (coder != null) for (i in coder) people += '\n^^$i^^';
			people += '\n\n@Charting@';
			if (charters != null) for (i in charters) people += '\n^^$i^^';
			return people.toUpperCase();
		}
		else return 'awkward..\nWhere are.. \nmy..\ncredits..?';
		
	}
}

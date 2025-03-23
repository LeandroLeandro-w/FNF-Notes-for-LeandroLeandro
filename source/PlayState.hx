package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.Json;
import lime.ui.Window;
import openfl.Assets;

typedef SongData = {
    var song:String;
    var bpm:Float;
    var notes:Array<NoteSection>;
}

typedef NoteSection = {
    var sectionNotes:Array<Array<Dynamic>>;
    var mustHitSection:Bool;
}

class PlayState extends FlxState
{
    var square:FlxSprite;
    var notesAttack:FlxTypedGroup<TaggedSprite>;
    
    var songData:SongData;
    var bpm:Float = 10;
    var crochet:Float = 60 / 100 * 1000; 
    var stepCrochet:Float = 60 / 100 * 1000 / 4; 
    var songPosition:Float = 0; 
    var lastStep:Int = -1;
    var curStep:Int = 0;
    var curBeat:Int = 0;
    
    var strumLine:Float = 50;
    var noteSpeed:Float = 0.1; 
    
    var strumLineNotes:FlxTypedGroup<FlxSprite>;
    
    override public function create()
    {
        super.create();
        
        loadSong("test-song");
        
        strumLineNotes = new FlxTypedGroup<FlxSprite>();
        add(strumLineNotes);
        
        notesAttack = new FlxTypedGroup<TaggedSprite>();
        add(notesAttack);
        
        createStrumLine();
        
        generarFlechas();
    }
    
    function loadSong(songName:String)
    {
        var jsonData:String = Assets.getText("assets/data/" + songName + ".json");
        songData = Json.parse(jsonData);
        
        bpm = songData.bpm;
        
        crochet = 60 / bpm * 1000;
        stepCrochet = crochet / 4;
    }
    
    function createStrumLine()
    {
        var horizontalSpacing:Float = 60;
        var directions = ["left", "down", "up", "right"];
        var colors = [0xffff0000, 0xffffff00, 0xff00ff00, 0xff0000ff];
        
        for (i in 0...4)
        {
            var receptor = new FlxSprite(i * horizontalSpacing, strumLine);
            receptor.makeGraphic(40, 40, colors[i]);
            strumLineNotes.add(receptor);
        }
    }
    
    function generarFlechas()
    {
        var directionMap:Map<Int, String> = [
            0 => "left",
            1 => "down",
            2 => "up",
            3 => "right"
        ];
        
        var colorMap:Map<String, Int> = [
            "left" => 0xffff0000,   // Rojo
            "down" => 0xffffff00,   // Amarillo
            "up" => 0xff00ff00,     // Verde
            "right" => 0xff0000ff   // Azul
        ];
        
        var horizontalSpacing:Float = 60;
        
        for (section in songData.notes)
        {
            var playerNotes = section.mustHitSection;
            
            for (i in 0...section.sectionNotes.length)
            {
                var note = section.sectionNotes[i];
                var strumTime:Float = note[0]; 
                var noteData:Int = Std.int(note[1]) % 4; 
                var direction = directionMap[noteData];
                
                if (playerNotes || note[1] > 3)
                {
                    var initialY = -2000;
                    
                    var newNote = new TaggedSprite(noteData * horizontalSpacing, initialY, strumTime);
                    newNote.tag = direction;
                    
                    var color = colorMap[direction];
                    newNote.makeGraphic(20, 20, color);
                    
                    notesAttack.add(newNote);
                }
            }
        }
    }
    
    function updateNotePositions()
    {
        for (note in notesAttack.members)
        {
            if (note != null)
            {
                note.y = -(strumLine - (note.strumTime - songPosition) * noteSpeed);
                note.canBeHit = (note.strumTime > songPosition - 166.67) && 
                                (note.strumTime < songPosition + 166.67);
            }
        }
    }
    
    function updateBeatAndStep()
    {
        curStep = Math.floor(songPosition / stepCrochet);
        
        if (curStep > lastStep)
        {
            for (i in lastStep + 1...curStep + 1)
            {
                stepHit(i);
            }
            lastStep = curStep;
        }
        
        curBeat = Math.floor(curStep / 4);
    }
    
    function stepHit(step:Int)
    {
        if (step % 4 == 0)
        {
            beatHit(Math.floor(step / 4));
        }
    }
    
    function beatHit(beat:Int)
    {
    }
   
	var notaspresionadas:Int = 0;
	var notasfalladas:Int = 0;
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        songPosition += elapsed * 1000;
        
        updateBeatAndStep();
        
        updateNotePositions();
        
        for (note in notesAttack.members)
        {
            if (note != null && note.canBeHit)
            {
                if ((note.tag == "left" && FlxG.keys.justPressed.LEFT) ||
                    (note.tag == "down" && FlxG.keys.justPressed.DOWN) ||
                    (note.tag == "up" && FlxG.keys.justPressed.UP) ||
                    (note.tag == "right" && FlxG.keys.justPressed.RIGHT))
                {
                    trace("¡Nota golpeada: " + note.tag + "!");
                    note.kill();
                }
                
                if (note.y > strumLine - 100)
                {
                    trace("Nota perdida: " + note.tag);
                    note.kill();
                }
            }
        }
    }
}
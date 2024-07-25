using Godot;
using System;

public partial class main_game : Node2D
{
	[Export]
	private player player;
	[Export]
	private camera_follower camera;

	private Node2D currentMap;

	public override void _Ready()
	{
		var starterMap = GD.Load<PackedScene>("res://game_components/map_pieces/map_0.tscn");
		currentMap = starterMap.Instantiate() as Node2D;
		AddChild(currentMap);
		ConfigurePlayerKillers();
	}

	public override void _PhysicsProcess(double delta)
	{
	}

	public void KillPlayer()
	{
		player.die();
	}

	public void ConfigurePlayerKillers()
	{
		System.Diagnostics.Debug.Assert(currentMap != null);
		TileMap playerKillers = currentMap.GetNode<TileMap>("Killer");
		// get the positions that exist inside the tilemap playerKillers
		var cellsWithKillers = playerKillers.GetUsedCells(0);
		for (cell in cellsWithKillers)
		{
			var area = new Area2D();
			area.Position = playerKillers.MapToWorld(cell);
			area.AddToGroup("player_killer");
			area.Connect("body_entered", nameof(KillPlayer));
			AddChild(area);
		}


	}



	// func configure_player_killer():
	// if not has_node("map"):
	// 	return
	// for player_killer in $map.get_children():
	// 	if player_killer.name == "player_killer":
	// 		for area in player_killer.get_children():
	// 			assert(area is Area2D)
	// 			if area.has_meta("type") and area.get_meta("type") == "area" and area is Area2D:
	// 				area.connect("body_entered", _on_Area2D_body_entered)

}

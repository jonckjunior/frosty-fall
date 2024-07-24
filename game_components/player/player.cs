using Godot;
using System;

public partial class player : CharacterBody2D
{
	[Export]
	public float playerSpeed = 300f;

	private RayCast2D direction;
	private float maxSteering = 0.1f;

	public override void _Ready()
	{
		direction = GetNode<RayCast2D>("Direction");
	}
	public override void _PhysicsProcess(double delta)
	{

		Velocity = new Vector2(Mathf.Cos(direction.Rotation), Mathf.Sin(direction.Rotation)) * playerSpeed;

		MoveAndSlide();
	}
}

using Godot;
using System;

public partial class player : CharacterBody2D
{
	[Export]
	public float playerSpeed = 300f;

	private RayCast2D direction;
	private float maxSteering = 0.1f;
	private AnimatedSprite2D animation;

	public override void _Ready()
	{
		direction = GetNode<RayCast2D>("Direction");
		animation = GetNode<AnimatedSprite2D>("Animation");
	}
	public override void _PhysicsProcess(double delta)
	{

		// Velocity = new Vector2(Mathf.Cos(direction.Rotation), Mathf.Sin(direction.Rotation)) * playerSpeed;
		float horizontal = Input.GetAxis("left", "right");
		float vertical = Input.GetAxis("up", "down");
		Velocity = new Vector2(horizontal, vertical) * playerSpeed;

		MoveAndSlide();
	}

	public void die()
	{
		QueueFree();
	}
}

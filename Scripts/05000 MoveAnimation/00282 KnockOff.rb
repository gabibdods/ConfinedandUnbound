ya = Yuki::Animation
# Knock Off
animation_user = ya.wait(0.1)
animation_target = ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'KnockOff', :animation], [:set_rect, 0, 0, 100, 95], [:zoom=, 0.75], [:set_origin, 50, 95])
main_t_anim = ya.resolved
animation_target.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :target, :target))
main_t_anim.play_before(ya.se_play('moves/KnockOff'))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 100, 95))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 95, 100, 95))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 190, 100, 95))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 285, 100, 95))
main_t_anim.play_before(ya.wait(0.2))
animation_target.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:knock_off, :first_use, animation_user, animation_target)

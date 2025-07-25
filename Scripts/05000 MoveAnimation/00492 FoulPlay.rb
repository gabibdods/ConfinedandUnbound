ya = Yuki::Animation
# FoulPlay
animation_user = ya.wait(0.1)
animation_target = ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'FoulPlay', :animation], [:set_rect, 0, 0, 104, 192], [:zoom=, 1], [:set_origin, 52, 132])
main_t_anim = ya.resolved
animation_target.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :target, :target))
main_t_anim.play_before(ya.se_play('moves/FoulPlay'))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.2))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 104, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.12))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 208, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.12))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 312, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.1))
animation_target.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:foul_play, :first_use, animation_user, animation_target)

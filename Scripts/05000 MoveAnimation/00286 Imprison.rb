ya = Yuki::Animation
# Imprison
animation_target = ya.wait(0.1)
animation_user = ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'Imprison', :animation], [:set_rect, 0, 0, 104, 192], [:zoom=, 0.75], [:set_origin, 52, 132])
main_t_anim = ya.resolved
animation_user.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :user, :user))
main_t_anim.play_before(ya.se_play('moves/Imprison'))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.18))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 104, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.18))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 208, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.15))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 312, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.15))
animation_user.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:imprison, :first_use, animation_user, animation_target)

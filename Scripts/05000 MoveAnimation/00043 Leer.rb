ya = Yuki::Animation
# Leer
animation_target = ya.wait(0.1)
animation_user = ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'Leer', :animation], [:set_rect, 0, 0, 104, 192], [:zoom=, 0.25], [:set_origin, 0, 190])
main_t_anim = ya.resolved
animation_user.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :user, :user))
main_t_anim.play_before(ya.se_play('moves/Leer'))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.075))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 104, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.075))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 208, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.1))
animation_user.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:leer, :first_use, animation_user, animation_target)

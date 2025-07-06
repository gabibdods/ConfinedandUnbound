ya = Yuki::Animation
# Growl
animation_target = ya.wait(0.1)
animation_user = ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'Growl', :animation], [:set_rect, 0, 0, 208, 192], [:zoom=, 0.5], [:set_origin, 104, 132])
main_t_anim = ya.resolved
animation_user.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :user, :user))
main_t_anim.play_before(ya.send_command_to(:user, :cry))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 208, 192))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 208, 0, 208, 192))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 416, 0, 208, 192))
main_t_anim.play_before(ya.wait(0.085))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 624, 0, 208, 192))
main_t_anim.play_before(ya.wait(0.085))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 832, 0, 208, 192))
main_t_anim.play_before(ya.wait(0.085))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 1040, 0, 208, 192))
main_t_anim.play_before(ya.wait(0.1))
animation_user.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:growl, :first_use, animation_target, animation_user)

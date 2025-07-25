ya = Yuki::Animation
# SleepTalk
animation_target = ya.wait(0.1)
animation_user = ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'SleepTalk', :animation], [:set_rect, 0, 0, 208, 192], [:zoom=, 0.75], [:set_origin, 104, 132])
main_t_anim = ya.resolved
animation_user.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :user, :user))
main_t_anim.play_before(ya.send_command_to(:user, :cry, volume = 40))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 208, 192))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 208, 0, 208, 192))
main_t_anim.play_before(ya.wait(0.1))
animation_user.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:sleep_talk, :first_use, animation_target, animation_user)

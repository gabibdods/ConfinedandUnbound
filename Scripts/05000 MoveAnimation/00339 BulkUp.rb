ya = Yuki::Animation
# BulkUp
animation_target = ya.wait(0.1)
animation_user = ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'BulkUp', :animation], [:set_rect, 0, 0, 192, 192], [:zoom=, 0.75], [:set_origin, 96, 130])
main_t_anim = ya.resolved
animation_user.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :user, :user))
main_t_anim.play_before(ya.se_play('moves/BulkUp'))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 192, 192))
main_t_anim.play_before(ya.wait(0.085))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 192, 0, 192, 192))
main_t_anim.play_before(ya.wait(0.075))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 384, 0, 192, 192))
main_t_anim.play_before(ya.wait(0.1))
animation_user.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:bulk_up, :first_use, animation_user, animation_target)

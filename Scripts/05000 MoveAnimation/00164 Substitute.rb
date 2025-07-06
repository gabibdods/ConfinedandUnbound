ya = Yuki::Animation
animation_user = Yuki::Animation::UserBankRelativeAnimation.new
# Substitute
animation_target = ya.wait(0.1)
animation_user.play_on_bank(0, ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'Substitute_0', :animation], [:set_rect, 0, 0, 104, 192], [:zoom=, 1], [:set_origin, 52, 170]))
animation_user.play_on_bank(1, ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'Substitute_1', :animation], [:set_rect, 0, 0, 104, 192], [:zoom=, 1.25], [:set_origin, 52, 170]))
main_t_anim = ya.resolved
animation_user.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :user, :user))
main_t_anim.play_before(ya.se_play('moves/Substitute'))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 104, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 208, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 312, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 416, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 520, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 624, 0, 104, 192))
main_t_anim.play_before(ya.wait(0.5))
animation_user.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:substitute, :first_use, animation_user, animation_target)

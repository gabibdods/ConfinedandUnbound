ya = Yuki::Animation
animation_target = Yuki::Animation::UserBankRelativeAnimation.new
# HornAttack
animation_user = ya.wait(0.1)
animation_target.play_on_bank(0, ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'HornAttack_0', :animation], [:set_rect, 0, 0, 104, 192], [:zoom=, 0.75], [:set_origin, 52, 132]))
animation_target.play_on_bank(1, ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'HornAttack_1', :animation], [:set_rect, 0, 0, 104, 192], [:zoom=, 0.75], [:set_origin, 52, 132]))
main_t_anim = ya.resolved
animation_target.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :target, :target))
main_t_anim.play_before(ya.se_play('moves/HornAttack'))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 104, 90))
main_t_anim.play_before(ya.wait(0.12))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 104, 0, 104, 90))
main_t_anim.play_before(ya.wait(0.12))
animation_target.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:horn_attack, :first_use, animation_user, animation_target)

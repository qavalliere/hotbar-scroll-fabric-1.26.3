package com.example.hotbarscroll;

import com.mojang.blaze3d.platform.InputConstants;
import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.fabric.api.client.event.lifecycle.v1.ClientTickEvents;
import net.fabricmc.fabric.api.client.keymapping.v1.KeyMappingHelper;
import net.minecraft.client.KeyMapping;
import net.minecraft.world.entity.player.Inventory;

public class HotbarScrollMod implements ClientModInitializer {
    public static final String MOD_ID = "hotbarscroll";

    private static KeyMapping scrollLeftKey;
    private static KeyMapping scrollRightKey;

    @Override
    public void onInitializeClient() {
        scrollLeftKey = KeyMappingHelper.registerKeyMapping(new KeyMapping(
                "key." + MOD_ID + ".scroll_left",
                InputConstants.Type.KEYBOARD,
                InputConstants.UNKNOWN.getValue(),
                KeyMapping.Category.INVENTORY
        ));

        scrollRightKey = KeyMappingHelper.registerKeyMapping(new KeyMapping(
                "key." + MOD_ID + ".scroll_right",
                InputConstants.Type.KEYBOARD,
                InputConstants.UNKNOWN.getValue(),
                KeyMapping.Category.INVENTORY
        ));

        ClientTickEvents.END_CLIENT_TICK.register(client -> {
            if (client.player == null) return;
            if (client.gui != null && client.gui.screen() != null) return;

            Inventory inventory = client.player.getInventory();

            while (scrollLeftKey.consumeClick()) {
                int current = inventory.getSelectedSlot();
                inventory.setSelectedSlot((current - 1 + 9) % 9);
            }

            while (scrollRightKey.consumeClick()) {
                int current = inventory.getSelectedSlot();
                inventory.setSelectedSlot((current + 1) % 9);
            }
        });
    }
}

/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Copyright (c) 2020, The Linux Foundation. All rights reserved.
 * Copyright (c) 2020 XiaoMi, Inc. All rights reserved.
 */

#ifndef _MI_DISP_LHBM_H_
#define _MI_DISP_LHBM_H_

#include <linux/types.h>
#include <linux/wait.h>
#include <linux/kthread.h>
#include <linux/atomic.h>

#include "dsi_panel.h"
#include "dsi_display.h"
#include "mi_disp_feature.h"
#include "mi_sde_connector.h"

enum {
	FOD_EVENT_UP = 0,
	FOD_EVENT_DOWN = 1,
	FOD_EVENT_MAX
};

enum mi_panel_op_code {
	MI_FOD_HBM_ON = 0,
	MI_FOD_HBM_OFF,
	MI_FOD_AOD_TO_NORMAL,
	MI_FOD_NORMAL_TO_AOD,
};

enum lhbm_target_brightness_state {
	LHBM_TARGET_BRIGHTNESS_NONE,
	LHBM_TARGET_BRIGHTNESS_WHITE_1000NIT,
	LHBM_TARGET_BRIGHTNESS_WHITE_110NIT,
	LHBM_TARGET_BRIGHTNESS_GREEN_500NIT,
	LHBM_TARGET_BRIGHTNESS_MAX
};

enum fod_ui_ready_state {
	LOCAL_HBM_UI_NONE = 0,
	GLOBAL_FOD_HBM_OVERLAY = BIT(0),
	GLOBAL_FOD_ICON = BIT(1),
	FOD_LOW_BRIGHTNESS_CAPTURE = BIT(2),
	LOCAL_HBM_UI_READY  = BIT(3)
};

struct disp_lhbm_fod {
	struct dsi_display *display;

	struct task_struct *fod_thread;
	wait_queue_head_t fod_pending_wq;

	struct list_head event_list;
	spinlock_t spinlock;

	atomic_t allow_tx_lhbm;
	atomic_t fingerprint_status;
	atomic_t last_fod_status;

	struct mi_layer_flags layer_flags;

	int target_brightness;
};

struct lhbm_fod_event {
	bool from_touch;
	int fod_status;

	struct list_head link;
};

bool is_local_hbm(int disp_id);
bool mi_disp_lhbm_fod_enabled(struct dsi_panel *panel);
int mi_disp_lhbm_fod_thread_create(struct disp_feature *df, int disp_id);
int mi_disp_lhbm_fod_thread_destroy(struct disp_feature *df, int disp_id);
struct disp_lhbm_fod *mi_get_disp_lhbm_fod(int disp_id);
int mi_disp_lhbm_fod_set_fingerprint_status(struct dsi_panel *panel,
		int fingerprint_status);
int mi_disp_lhbm_fod_allow_tx_lhbm(struct dsi_display *display, bool enable);
int mi_disp_lhbm_fod_update_layer_state(struct dsi_display *display,
		struct mi_layer_flags flags);
int mi_disp_lhbm_aod_to_normal_optimize(struct dsi_display *display,
		bool enable);
int mi_disp_lhbm_fod_set_finger_event(int disp_id, u32 fod_status, bool from_touch);

#endif /* _MI_DISP_LHBM_H_ */

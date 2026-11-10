import { defineConfig } from "wxt";

export default defineConfig({
	manifest: {
		browser_specific_settings: {
			gecko: {
				data_collection_permissions: {
					optional: [],
					required: [],
				},
				id: "<extension-id>",
			},
		},
		permissions: ["contextualIdentities", "tabs"],
	},
	manifestVersion: 3,
});

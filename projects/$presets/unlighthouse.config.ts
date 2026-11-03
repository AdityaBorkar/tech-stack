import { defineUnlighthouseConfig } from "unlighthouse/config";

// Replace with your production URL.
const SITE_URL = "https://example.com";

export default defineUnlighthouseConfig({
	scanner: {
		// device: "desktop",
		dynamicSampling: false,
		samples: 3,
		throttle: true,
	},
	site: SITE_URL,
});

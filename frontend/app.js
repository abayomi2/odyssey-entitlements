const { createApp } = Vue;

createApp({
    data() {
        return {
            auditors: [],
            loading: false,
            error: null,
            // Change this to an empty string for a relative path
            apiBaseUrl: '' 
        };
    },
    methods: {
        async fetchAuditors() {
            this.loading = true;
            this.error = null;
            try {
                // This will now call /api/auditors on the current domain
                const response = await fetch(`${this.apiBaseUrl}/api/auditors`);
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                this.auditors = await response.json();
            } catch (e) {
                this.error = `Failed to fetch auditors: ${e.message}`;
            } finally {
                this.loading = false;
            }
        },
        async ingestData() {
            this.loading = true;
            this.error = null;
            try {
                const response = await fetch(`${this.apiBaseUrl}/api/auditors/ingest`, { method: 'POST' });
                if (!response.ok) {
                    throw new Error(`Server returned status: ${response.status}`);
                }
                alert('Data ingestion started successfully! Click "Refresh Auditors" in a moment to see the data.');
                this.auditors = []; // Clear current list
            } catch (e) {
                this.error = `Failed to start ingestion: ${e.message}`;
            } finally {
                this.loading = false;
            }
        }
    },
    mounted() {
        this.fetchAuditors();
    }
}).mount('#app');
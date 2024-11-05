/** @type {import('next').NextConfig} */
const nextConfig = {
    webpack: (config, { isServer }) => {
        if (!isServer) {
            config.resolve.fallback = {
                ...config.resolve.fallback,
                dns: false,
                buffer: false,
                stream: false,
            };
        }
        return config;
    },
};

export default nextConfig;

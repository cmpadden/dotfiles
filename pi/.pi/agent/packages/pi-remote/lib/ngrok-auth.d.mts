export const NGROK_AUTHTOKEN_URL: string;
export function ngrokConfigPaths(env?: NodeJS.ProcessEnv, platform?: NodeJS.Platform, home?: string): string[];
export function resolveNgrokAuthtoken(options?: { env?: NodeJS.ProcessEnv; paths?: string[] }): Promise<string | undefined>;

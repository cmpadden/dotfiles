// Session-local FIFO concurrency limit; acquire resolves undefined if cancelled while waiting.
export class DelegateQueue {
  private running = 0;
  private waiting: Array<() => void> = [];
  private readonly limit: number;

  constructor(limit = 3) {
    this.limit = limit;
  }

  acquire(signal: AbortSignal): Promise<(() => void) | undefined> {
    if (signal.aborted) return Promise.resolve(undefined);
    return new Promise((resolve) => {
      const cancel = () => {
        this.waiting = this.waiting.filter((entry) => entry !== start);
        resolve(undefined);
      };
      const start = () => {
        signal.removeEventListener("abort", cancel);
        this.running++;
        let released = false;
        resolve(() => {
          if (released) return;
          released = true;
          this.running--;
          this.drain();
        });
      };
      signal.addEventListener("abort", cancel, { once: true });
      this.waiting.push(start);
      this.drain();
    });
  }

  private drain() {
    while (this.running < this.limit && this.waiting.length) this.waiting.shift()!();
  }
}

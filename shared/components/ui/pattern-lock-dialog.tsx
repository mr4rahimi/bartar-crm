'use client';

import { useRef, useState } from 'react';
import { Dialog } from './dialog';
import { Button } from './button';

type PatternLockDialogProps = {
  open: boolean;
  onClose: () => void;
  onSubmit: (pattern: string) => void;
};

const DOTS = [1, 2, 3, 4, 5, 6, 7, 8, 9];
const SIZE = 260;
const CELL = SIZE / 3;

function dotCenter(index: number) {
  const row = Math.floor(index / 3);
  const column = index % 3;
  return { x: column * CELL + CELL / 2, y: row * CELL + CELL / 2 };
}

/** قفل الگوی ۳×۳ — خروجی: ترتیب شماره‌ی نقطه‌ها (مثلاً L انگلیسی = 147789…) */
export function PatternLockDialog({ open, onClose, onSubmit }: PatternLockDialogProps) {
  const [sequence, setSequence] = useState<number[]>([]);
  const [isDrawing, setIsDrawing] = useState(false);
  const boardRef = useRef<HTMLDivElement>(null);

  const hitTest = (clientX: number, clientY: number): number | null => {
    const board = boardRef.current;
    if (!board) return null;
    const rect = board.getBoundingClientRect();
    const x = ((clientX - rect.left) / rect.width) * SIZE;
    const y = ((clientY - rect.top) / rect.height) * SIZE;

    for (let index = 0; index < 9; index++) {
      const center = dotCenter(index);
      const distance = Math.hypot(center.x - x, center.y - y);
      if (distance <= CELL * 0.34) return index + 1;
    }
    return null;
  };

  const addPoint = (point: number | null) => {
    if (point === null) return;
    setSequence((current) => (current.includes(point) ? current : [...current, point]));
  };

  const reset = () => setSequence([]);

  const handleClose = () => { reset(); onClose(); };

  const points = sequence.map((point) => dotCenter(point - 1));
  const polyline = points.map((point) => `${point.x},${point.y}`).join(' ');

  return (
    <Dialog open={open} onClose={handleClose} title="رسم الگوی قفل">
      <div className="flex flex-col items-center gap-3.5">
        <p className="text-center text-[12px] text-muted-foreground">
          الگو را با انگشت یا ماوس بکشید (یا نقطه‌ها را به ترتیب بزنید)
        </p>

        <div
          ref={boardRef}
          className="relative touch-none select-none rounded-xl border border-border bg-background p-2"
          style={{ width: SIZE, height: SIZE }}
          onPointerDown={(event) => {
            event.currentTarget.setPointerCapture(event.pointerId);
            setIsDrawing(true);
            addPoint(hitTest(event.clientX, event.clientY));
          }}
          onPointerMove={(event) => {
            if (!isDrawing) return;
            addPoint(hitTest(event.clientX, event.clientY));
          }}
          onPointerUp={() => setIsDrawing(false)}
          onPointerCancel={() => setIsDrawing(false)}
        >
          <svg
            viewBox={`0 0 ${SIZE} ${SIZE}`}
            className="pointer-events-none absolute inset-0 h-full w-full"
          >
            {points.length > 1 && (
              <polyline
                points={polyline}
                fill="none"
                stroke="currentColor"
                strokeWidth={3}
                strokeLinecap="round"
                strokeLinejoin="round"
                className="text-primary"
              />
            )}
          </svg>

          {DOTS.map((dot, index) => {
            const center = dotCenter(index);
            const order = sequence.indexOf(dot);
            return (
              <div
                key={dot}
                className="pointer-events-none absolute flex items-center justify-center rounded-full border-2 text-[11px] font-extrabold transition-colors"
                style={{
                  width: 40,
                  height: 40,
                  left: `${(center.x / SIZE) * 100}%`,
                  top: `${(center.y / SIZE) * 100}%`,
                  transform: 'translate(-50%, -50%)',
                  borderColor: order >= 0 ? 'hsl(var(--primary))' : 'hsl(var(--border))',
                  background: order >= 0 ? 'hsl(var(--primary))' : 'transparent',
                  color: order >= 0 ? 'hsl(var(--primary-foreground))' : 'transparent',
                }}
              >
                {order >= 0 ? order + 1 : ''}
              </div>
            );
          })}
        </div>

        <div dir="ltr" className="min-h-6 text-[15px] font-extrabold tracking-widest">
          {sequence.join('')}
        </div>

        <div className="flex w-full gap-2">
          <Button
            disabled={sequence.length < 2}
            onClick={() => { onSubmit(sequence.join('')); reset(); onClose(); }}
          >
            تایید الگو
          </Button>
          <Button variant="outline" onClick={reset}>
            پاک کردن
          </Button>
        </div>
      </div>
    </Dialog>
  );
}

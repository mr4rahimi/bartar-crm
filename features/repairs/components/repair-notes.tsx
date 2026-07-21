'use client';

import { useState } from 'react';
import { Loader2, MessageSquarePlus, StickyNote } from 'lucide-react';
import { Button } from '@/shared/components/ui/button';
import { Textarea } from '@/shared/components/ui/textarea';
import { useToast } from '@/shared/components/providers/toast-provider';
import { useRepairNotes, useAddRepairNote } from '../hooks/use-repair-notes';

export function RepairNotes({ ticketId }: { ticketId: string }) {
  const { toast } = useToast();
  const notes = useRepairNotes(ticketId);
  const addNote = useAddRepairNote(ticketId);
  const [body, setBody] = useState('');

  const submit = () => {
    if (!body.trim()) {
      toast('متن یادداشت را وارد کنید', 'error');
      return;
    }
    addNote.mutate(body.trim(), {
      onSuccess: () => { setBody(''); toast('یادداشت ثبت شد'); },
      onError: (error) => toast(error.message, 'error'),
    });
  };

  return (
    <div className="space-y-3">
      <div className="space-y-2">
        <Textarea
          rows={2}
          placeholder="یادداشتی برای پذیرش، مدیر و تعمیرکاران بعدی بنویسید…"
          value={body}
          onChange={(event) => setBody(event.target.value)}
        />
        <Button
          className="h-9 w-auto px-4 text-[12.5px]"
          disabled={addNote.isPending}
          onClick={submit}
        >
          {addNote.isPending ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <MessageSquarePlus className="h-4 w-4" />
          )}
          ثبت یادداشت
        </Button>
      </div>

      {notes.isLoading && (
        <p className="py-2 text-center text-[12px] text-muted-foreground">در حال بارگذاری…</p>
      )}

      {notes.data && notes.data.length === 0 && (
        <div className="flex flex-col items-center gap-1.5 py-4 text-muted-foreground">
          <StickyNote className="h-6 w-6" />
          <p className="text-[12px]">هنوز یادداشتی ثبت نشده</p>
        </div>
      )}

      <div className="space-y-2">
        {notes.data?.map((note) => (
          <div key={note.id} className="rounded-md border border-border bg-background px-3 py-2.5">
            <p className="whitespace-pre-wrap text-[12.5px] leading-6">{note.body}</p>
            <div className="mt-1.5 flex items-center gap-2 text-[10.5px] text-muted-foreground">
              <span className="font-bold">{note.authorName}</span>
              <span>{new Date(note.createdAt).toLocaleString('fa-IR')}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

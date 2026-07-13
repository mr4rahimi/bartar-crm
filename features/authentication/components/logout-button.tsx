'use client';

import { useRouter } from 'next/navigation';
import { Loader2 } from 'lucide-react';
import { useLogout } from '../hooks/use-logout';
import { Button } from '@/shared/components/ui/button';

export function LogoutButton() {
  const router = useRouter();
  const logout = useLogout();

  const handleLogout = () => {
    logout.mutate(undefined, {
      onSuccess: () => {
        router.push('/auth/login');
        router.refresh();
      },
    });
  };

  return (
    <Button variant="outline" className="w-auto" onClick={handleLogout} disabled={logout.isPending}>
      {logout.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
      خروج
    </Button>
  );
}

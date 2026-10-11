-- ご意見掲示板 テーブル (Supabase / PostgreSQL)
-- Supabase の SQL Editor に貼り付けて実行してください。

-- ============================================================
-- 1. テーブル作成
-- ============================================================
create table if not exists public.board_posts (
    id         bigint generated always as identity primary key,
    nickname   text        not null check (char_length(btrim(nickname)) between 1 and 20),  -- モックの maxlength="20"
    message    text        not null check (char_length(btrim(message))  between 1 and 200), -- モックの maxlength="200"
    created_at timestamptz not null default now()
);

comment on table public.board_posts is 'ご意見掲示板の投稿';

-- 新しい順の一覧表示用インデックス
create index if not exists board_posts_created_at_idx
    on public.board_posts (created_at desc);

-- ============================================================
-- 2. RLS (行レベルセキュリティ) を有効化
-- ============================================================
alter table public.board_posts enable row level security;

-- ============================================================
-- 3. ポリシー
--    ログイン不要の掲示板なので anon / authenticated の両方に
--    「閲覧」と「投稿」だけを許可します。
--    UPDATE / DELETE のポリシーは作らない = 誰も編集・削除できません。
-- ============================================================
drop policy if exists "board_posts_select_all" on public.board_posts;
create policy "board_posts_select_all"
    on public.board_posts
    for select
    to anon, authenticated
    using (true);

drop policy if exists "board_posts_insert_all" on public.board_posts;
create policy "board_posts_insert_all"
    on public.board_posts
    for insert
    to anon, authenticated
    with check (
        char_length(btrim(nickname)) between 1 and 20
        and char_length(btrim(message)) between 1 and 200
    );

-- ============================================================
-- 4. ダミーデータ
--    (SQL Editor は postgres ロールで実行されるため RLS をバイパスして挿入されます)
-- ============================================================
insert into public.board_posts (nickname, message, created_at) values
    ('たろう',   'はじめまして！サイトを見ました。とても見やすいです。', now() - interval '3 days'),
    ('はなこ',   'かめの写真がかわいかったです。もっと見たいです。',     now() - interval '2 days'),
    ('ゲスト',   'スマホでも読みやすくなると嬉しいです。',               now() - interval '1 day'),
    ('かめ好き', '更新を楽しみにしています！',                           now() - interval '2 hours');

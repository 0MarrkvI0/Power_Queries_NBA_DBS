SELECT
    team_stats.team_id,
    team_stats.team_name,

    team_stats.number_away_matches,
    ROUND((team_stats.number_away_matches::NUMERIC / team_stats.total_games) * 100, 2) AS away_match_percent,

    team_stats.number_home_matches,
    ROUND((team_stats.number_home_matches::NUMERIC / team_stats.total_games) * 100, 2) AS home_match_percent,

    team_stats.total_games

FROM (
    SELECT
        th.team_id,
        th.city || ' ' || th.nickname AS team_name,

        COUNT(CASE WHEN th.team_id = g.away_team_id THEN 1 END) AS number_away_matches,
        COUNT(CASE WHEN th.team_id = g.home_team_id THEN 1 END) AS number_home_matches,

        COUNT(*) AS total_games

    FROM games AS g
    JOIN team_history AS th
        ON g.home_team_id = th.team_id OR g.away_team_id = th.team_id

    WHERE
        (
            th.year_active_till = 2019
            AND g.game_date >= MAKE_DATE(th.year_founded, 7, 1)
        )
        OR
        (
            th.year_active_till != 2019
            AND g.game_date >= MAKE_DATE(th.year_founded, 7, 1)
            AND g.game_date <= MAKE_DATE(th.year_active_till, 6, 30)
        )

    GROUP BY th.team_id, th.city, th.nickname
) AS team_stats

ORDER BY team_stats.team_id, team_stats.team_name;

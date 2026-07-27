#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "PyYAML>=6.0",
#   "reportlab>=4.2",
# ]
# ///

"""Build the website CV as a print-ready PDF from the shared Jekyll data."""

from __future__ import annotations

import html
import shutil
from pathlib import Path
from typing import Any, Iterable

import yaml
from reportlab.lib import colors
from reportlab.lib.enums import TA_RIGHT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    HRFlowable,
    KeepTogether,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
CV_DATA_PATH = ROOT / "_data" / "cv.yml"
CONFIG_PATH = ROOT / "_config.yml"
OUTPUT_PATH = ROOT / "output" / "pdf" / "neil-ashton-cv.pdf"
SITE_PATH = ROOT / "assets" / "pdf" / "neil-ashton-cv.pdf"

BLUE = colors.HexColor("#285678")
TEXT = colors.HexColor("#25282B")
MUTED = colors.HexColor("#5F6469")
RULE = colors.HexColor("#CDD6DC")
PALE_BLUE = colors.HexColor("#E8EEF2")
WHITE = colors.white
CONTENT_WIDTH = A4[0] - 30 * mm


def load_yaml(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as stream:
        value = yaml.safe_load(stream)
    if not isinstance(value, dict):
        raise TypeError(f"{path} must contain a YAML mapping")
    return value


def assert_pdf_safe_text(value: Any, trail: str = "root") -> None:
    """Keep generated PDF text free of typographic dash encoding surprises."""

    if isinstance(value, dict):
        for key, item in value.items():
            assert_pdf_safe_text(item, f"{trail}.{key}")
    elif isinstance(value, list):
        for index, item in enumerate(value):
            assert_pdf_safe_text(item, f"{trail}[{index}]")
    elif isinstance(value, str):
        for prohibited in ("\u2013", "\u2014"):
            if prohibited in value:
                raise ValueError(f"Unicode dash found at {trail}: {value!r}")


def esc(value: Any) -> str:
    return html.escape(str(value), quote=True)


def linked(label: str, url: str | None) -> str:
    text = esc(label)
    if not url:
        return text
    return f'<link href="{esc(url)}" color="#285678">{text}</link>'


def make_styles() -> dict[str, ParagraphStyle]:
    sample = getSampleStyleSheet()
    return {
        "name": ParagraphStyle(
            "CVName",
            parent=sample["Normal"],
            fontName="Helvetica-Bold",
            fontSize=24,
            leading=27,
            textColor=TEXT,
            spaceAfter=2,
        ),
        "headline": ParagraphStyle(
            "CVHeadline",
            parent=sample["Normal"],
            fontName="Helvetica",
            fontSize=10.5,
            leading=13,
            textColor=BLUE,
            spaceAfter=4,
        ),
        "contact": ParagraphStyle(
            "CVContact",
            parent=sample["Normal"],
            fontName="Helvetica",
            fontSize=7.8,
            leading=10,
            textColor=MUTED,
        ),
        "summary": ParagraphStyle(
            "CVSummary",
            parent=sample["Normal"],
            fontName="Helvetica",
            fontSize=8.8,
            leading=12.2,
            textColor=TEXT,
        ),
        "section": ParagraphStyle(
            "CVSection",
            parent=sample["Normal"],
            fontName="Helvetica-Bold",
            fontSize=11.7,
            leading=14,
            textColor=BLUE,
            spaceBefore=8,
            spaceAfter=3,
            keepWithNext=True,
        ),
        "period": ParagraphStyle(
            "CVPeriod",
            parent=sample["Normal"],
            fontName="Helvetica-Bold",
            fontSize=7.5,
            leading=10,
            textColor=BLUE,
        ),
        "role": ParagraphStyle(
            "CVRole",
            parent=sample["Normal"],
            fontName="Helvetica-Bold",
            fontSize=9.1,
            leading=11.4,
            textColor=TEXT,
            spaceAfter=1,
        ),
        "organisation": ParagraphStyle(
            "CVOrganisation",
            parent=sample["Normal"],
            fontName="Helvetica",
            fontSize=7.9,
            leading=10.2,
            textColor=MUTED,
            spaceAfter=2.2,
        ),
        "body": ParagraphStyle(
            "CVBody",
            parent=sample["Normal"],
            fontName="Helvetica",
            fontSize=7.9,
            leading=10.5,
            textColor=TEXT,
            spaceAfter=2.2,
        ),
        "bullet": ParagraphStyle(
            "CVBullet",
            parent=sample["Normal"],
            fontName="Helvetica",
            fontSize=7.75,
            leading=10.2,
            leftIndent=8,
            firstLineIndent=0,
            bulletIndent=0,
            textColor=TEXT,
            spaceAfter=1.5,
        ),
        "small": ParagraphStyle(
            "CVSmall",
            parent=sample["Normal"],
            fontName="Helvetica",
            fontSize=7.35,
            leading=9.7,
            textColor=TEXT,
            spaceAfter=1.5,
        ),
        "small_muted": ParagraphStyle(
            "CVSmallMuted",
            parent=sample["Normal"],
            fontName="Helvetica",
            fontSize=7.15,
            leading=9.4,
            textColor=MUTED,
            spaceAfter=1.5,
        ),
        "footer": ParagraphStyle(
            "CVFooter",
            parent=sample["Normal"],
            fontName="Helvetica",
            fontSize=6.8,
            leading=8,
            textColor=MUTED,
        ),
        "footer_right": ParagraphStyle(
            "CVFooterRight",
            parent=sample["Normal"],
            fontName="Helvetica",
            fontSize=6.8,
            leading=8,
            textColor=MUTED,
            alignment=TA_RIGHT,
        ),
    }


def section_heading(title: str, styles: dict[str, ParagraphStyle]) -> list[Any]:
    return [
        Paragraph(esc(title), styles["section"]),
        HRFlowable(
            width="100%",
            thickness=0.55,
            color=BLUE,
            spaceBefore=0,
            spaceAfter=5,
        ),
    ]


def entry_table(
    period: str,
    role: str,
    organisation: str,
    organisation_url: str | None,
    details: Iterable[str],
    styles: dict[str, ParagraphStyle],
    *,
    location: str | None = None,
) -> Table:
    organisation_line = linked(organisation, organisation_url)
    if location:
        organisation_line += f"  |  {esc(location)}"

    content: list[Any] = [
        Paragraph(esc(role), styles["role"]),
        Paragraph(organisation_line, styles["organisation"]),
    ]
    content.extend(
        Paragraph(esc(detail), styles["bullet"], bulletText="-")
        for detail in details
    )

    table = Table(
        [[Paragraph(esc(period), styles["period"]), content]],
        colWidths=[30 * mm, CONTENT_WIDTH - 30 * mm],
        hAlign="LEFT",
        splitByRow=1,
    )
    table.setStyle(
        TableStyle(
            [
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 0),
                ("RIGHTPADDING", (0, 0), (0, -1), 7),
                ("RIGHTPADDING", (1, 0), (1, -1), 0),
                ("TOPPADDING", (0, 0), (-1, -1), 1.5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4.5),
            ]
        )
    )
    return table


def compact_entry(
    period: str,
    title: str,
    subtitle: str,
    description: str,
    url: str | None,
    styles: dict[str, ParagraphStyle],
) -> Table:
    content = [
        Paragraph(linked(title, url), styles["role"]),
        Paragraph(esc(subtitle), styles["organisation"]),
        Paragraph(esc(description), styles["body"]),
    ]
    table = Table(
        [[Paragraph(esc(period), styles["period"]), content]],
        colWidths=[30 * mm, CONTENT_WIDTH - 30 * mm],
        hAlign="LEFT",
    )
    table.setStyle(
        TableStyle(
            [
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 0),
                ("RIGHTPADDING", (0, 0), (0, -1), 7),
                ("RIGHTPADDING", (1, 0), (1, -1), 0),
                ("TOPPADDING", (0, 0), (-1, -1), 1),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3.5),
            ]
        )
    )
    return table


def education_and_standing_table(
    cv: dict[str, Any], styles: dict[str, ParagraphStyle]
) -> Table:
    education_flow: list[Any] = [
        Paragraph("Education", styles["section"]),
        HRFlowable(width="100%", thickness=0.55, color=BLUE, spaceAfter=5),
    ]
    for item in cv["education"]:
        education_flow.extend(
            [
                Paragraph(esc(item["period"]), styles["period"]),
                Paragraph(linked(item["degree"], item.get("url")), styles["role"]),
                Paragraph(esc(item["institution"]), styles["organisation"]),
            ]
        )
        if item.get("detail"):
            education_flow.append(Paragraph(esc(item["detail"]), styles["small_muted"]))
        education_flow.append(Spacer(1, 3))

    standing_flow: list[Any] = [
        Paragraph("Professional standing", styles["section"]),
        HRFlowable(width="100%", thickness=0.55, color=BLUE, spaceAfter=5),
    ]
    for item in cv["professional_standing"]:
        standing_flow.append(
            Table(
                [
                    [
                        Paragraph(esc(item["title"]), styles["small"]),
                        Paragraph(esc(item["period"]), styles["small_muted"]),
                    ]
                ],
                colWidths=[56 * mm, 20 * mm],
                style=TableStyle(
                    [
                        ("VALIGN", (0, 0), (-1, -1), "TOP"),
                        ("LEFTPADDING", (0, 0), (-1, -1), 0),
                        ("RIGHTPADDING", (0, 0), (-1, -1), 0),
                        ("TOPPADDING", (0, 0), (-1, -1), 0),
                        ("BOTTOMPADDING", (0, 0), (-1, -1), 2),
                    ]
                ),
            )
        )

    two_column = Table(
        [[education_flow, standing_flow]],
        colWidths=[92 * mm, 86 * mm],
        hAlign="LEFT",
    )
    two_column.setStyle(
        TableStyle(
            [
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (0, -1), 0),
                ("RIGHTPADDING", (0, 0), (0, -1), 7),
                ("LEFTPADDING", (1, 0), (1, -1), 7),
                ("RIGHTPADDING", (1, 0), (1, -1), 0),
                ("TOPPADDING", (0, 0), (-1, -1), 0),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
            ]
        )
    )
    return two_column


def build_pdf(cv: dict[str, Any], config: dict[str, Any]) -> None:
    styles = make_styles()
    current = config["current_position"]
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    SITE_PATH.parent.mkdir(parents=True, exist_ok=True)

    document = SimpleDocTemplate(
        str(OUTPUT_PATH),
        pagesize=A4,
        rightMargin=15 * mm,
        leftMargin=15 * mm,
        topMargin=13 * mm,
        bottomMargin=15 * mm,
        title="Neil Ashton - Curriculum Vitae",
        author="Neil Ashton",
        subject="Curriculum vitae of Neil Ashton",
        creator="neilashton.co.uk",
        pageCompression=1,
    )

    story: list[Any] = [
        Paragraph("Neil Ashton", styles["name"]),
        Paragraph(
            f"{esc(current['role'])}, {linked(current['organisation'], current['organisation_url'])}",
            styles["headline"],
        ),
        Paragraph(
            "  |  ".join(
                [
                    linked("neilashton.co.uk", "https://neilashton.co.uk"),
                    linked(config["email"], f"mailto:{config['email']}"),
                    linked("Google Scholar", f"https://scholar.google.com/citations?user={config['scholar_userid']}"),
                    linked("ORCID", f"https://orcid.org/{config['orcid_id']}"),
                    linked("LinkedIn", f"https://www.linkedin.com/in/{config['linkedin_username']}"),
                ]
            ),
            styles["contact"],
        ),
        Spacer(1, 5),
    ]

    summary_box = Table(
        [[Paragraph(esc(cv["summary"]), styles["summary"])]],
        colWidths=[document.width],
        hAlign="LEFT",
    )
    summary_box.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), PALE_BLUE),
                ("BOX", (0, 0), (-1, -1), 0.55, BLUE),
                ("LEFTPADDING", (0, 0), (-1, -1), 8),
                ("RIGHTPADDING", (0, 0), (-1, -1), 8),
                ("TOPPADDING", (0, 0), (-1, -1), 7),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
            ]
        )
    )
    story.extend([summary_box, Spacer(1, 4)])

    story.extend(section_heading("Experience", styles))
    for item in cv["experience"]:
        role = current["role"] if item.get("current") else item["role"]
        organisation = (
            current["organisation"] if item.get("current") else item["organisation"]
        )
        organisation_url = (
            current["organisation_url"]
            if item.get("current")
            else item.get("organisation_url")
        )
        story.append(
            KeepTogether(
                entry_table(
                    item["period"],
                    role,
                    organisation,
                    organisation_url,
                    item.get("highlights", []),
                    styles,
                    location=item.get("location"),
                )
            )
        )

    story.append(KeepTogether(education_and_standing_table(cv, styles)))

    leadership_block: list[Any] = section_heading(
        "Research leadership and public scholarship", styles
    )
    for item in cv["research_leadership"]:
        period = item["role"].split(",")[-1].strip() if "," in item["role"] else ""
        role = (
            item["role"].rsplit(",", 1)[0]
            if period and any(character.isdigit() for character in period)
            else item["role"]
        )
        if not any(character.isdigit() for character in period):
            period = "Current"
        url = item.get("url")
        if url and url.startswith("/"):
            url = f"https://neilashton.co.uk{url}"
        leadership_block.append(
            compact_entry(
                period,
                item["title"],
                role,
                item.get("pdf_description", item["description"]),
                url,
                styles,
            )
        )
    story.append(KeepTogether(leadership_block))

    story.extend(section_heading("Selected publications", styles))
    for index, item in enumerate(cv["publications"], start=1):
        citation = (
            f"{esc(item['authors'])}. "
            f"{linked(item['title'], item['url'])}. "
            f"<i>{esc(item['venue'])}</i>."
        )
        story.append(
            KeepTogether(
                Table(
                    [
                        [
                            Paragraph(f"{index}. {esc(item['year'])}", styles["period"]),
                            Paragraph(citation, styles["small"]),
                        ]
                    ],
                    colWidths=[20 * mm, CONTENT_WIDTH - 20 * mm],
                    hAlign="LEFT",
                    style=TableStyle(
                        [
                            ("VALIGN", (0, 0), (-1, -1), "TOP"),
                            ("LEFTPADDING", (0, 0), (-1, -1), 0),
                            ("RIGHTPADDING", (0, 0), (0, -1), 6),
                            ("RIGHTPADDING", (1, 0), (1, -1), 0),
                            ("TOPPADDING", (0, 0), (-1, -1), 0.5),
                            ("BOTTOMPADDING", (0, 0), (-1, -1), 2.4),
                        ]
                    ),
                )
            )
        )

    story.extend(section_heading("Selected invited talks", styles))
    for item in cv["talks"]:
        talk_text = (
            f"<b>{linked(item['host'], item.get('url'))}</b><br/>"
            f"{esc(item['title'])}"
        )
        story.append(
            KeepTogether(
                Table(
                    [
                        [
                            Paragraph(esc(item["date"]), styles["period"]),
                            Paragraph(esc(item["type"]), styles["small_muted"]),
                            Paragraph(talk_text, styles["small"]),
                        ]
                    ],
                    colWidths=[20 * mm, 28 * mm, CONTENT_WIDTH - 48 * mm],
                    hAlign="LEFT",
                    style=TableStyle(
                        [
                            ("VALIGN", (0, 0), (-1, -1), "TOP"),
                            ("LEFTPADDING", (0, 0), (-1, -1), 0),
                            ("RIGHTPADDING", (0, 0), (1, -1), 6),
                            ("RIGHTPADDING", (2, 0), (2, -1), 0),
                            ("TOPPADDING", (0, 0), (-1, -1), 0.5),
                            ("BOTTOMPADDING", (0, 0), (-1, -1), 2.7),
                        ]
                    ),
                )
            )
        )

    def draw_footer(canvas: Any, doc: Any) -> None:
        canvas.saveState()
        canvas.setStrokeColor(RULE)
        canvas.setLineWidth(0.4)
        canvas.line(15 * mm, 11 * mm, A4[0] - 15 * mm, 11 * mm)
        canvas.setFont("Helvetica", 6.8)
        canvas.setFillColor(MUTED)
        canvas.drawString(15 * mm, 7.3 * mm, f"neilashton.co.uk  |  Updated {cv['updated']}")
        canvas.drawRightString(A4[0] - 15 * mm, 7.3 * mm, f"Page {doc.page}")
        canvas.restoreState()

    document.build(story, onFirstPage=draw_footer, onLaterPages=draw_footer)
    shutil.copyfile(OUTPUT_PATH, SITE_PATH)


def main() -> None:
    cv = load_yaml(CV_DATA_PATH)
    config = load_yaml(CONFIG_PATH)
    assert_pdf_safe_text(cv)
    assert_pdf_safe_text(config["current_position"])
    build_pdf(cv, config)
    print(f"Built {OUTPUT_PATH.relative_to(ROOT)}")
    print(f"Copied {SITE_PATH.relative_to(ROOT)}")


if __name__ == "__main__":
    main()

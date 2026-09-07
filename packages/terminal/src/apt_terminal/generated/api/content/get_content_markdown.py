from http import HTTPStatus
from typing import Any

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.error import Error
from ...models.get_content_markdown_response_200 import GetContentMarkdownResponse200
from ...types import UNSET, Response, Unset


def _get_kwargs(
    *,
    page: Unset | int = UNSET,
    page_size: Unset | int = 50,
    q: Unset | str = UNSET,
    category: Unset | str = UNSET,
    tag: Unset | str = UNSET,
    source: Unset | str = UNSET,
    noted: Unset | bool = UNSET,
    doc: Unset | bool = UNSET,
    workspace: Unset | str = UNSET,
) -> dict[str, Any]:
    params: dict[str, Any] = {}

    params["page"] = page

    params["pageSize"] = page_size

    params["q"] = q

    params["category"] = category

    params["tag"] = tag

    params["source"] = source

    params["noted"] = noted

    params["doc"] = doc

    params["workspace"] = workspace

    params = {k: v for k, v in params.items() if v is not UNSET and v is not None}

    _kwargs: dict[str, Any] = {
        "method": "get",
        "url": "/content/markdown",
        "params": params,
    }

    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Error | GetContentMarkdownResponse200 | None:
    if response.status_code == 200:
        response_200 = GetContentMarkdownResponse200.from_dict(response.json())

        return response_200

    if response.status_code == 401:
        response_401 = Error.from_dict(response.json())

        return response_401

    if client.raise_on_unexpected_status:
        raise errors.UnexpectedStatus(response.status_code, response.content)
    else:
        return None


def _build_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Response[Error | GetContentMarkdownResponse200]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    *,
    client: AuthenticatedClient,
    page: Unset | int = UNSET,
    page_size: Unset | int = 50,
    q: Unset | str = UNSET,
    category: Unset | str = UNSET,
    tag: Unset | str = UNSET,
    source: Unset | str = UNSET,
    noted: Unset | bool = UNSET,
    doc: Unset | bool = UNSET,
    workspace: Unset | str = UNSET,
) -> Response[Error | GetContentMarkdownResponse200]:
    """List/search the caller's markdown documents (metadata only)

     Lists the caller’s documents, most-recently-updated first. Optional filters narrow the set: `q`
    (free-text, case-insensitive substring across title, body, category, and tags), `category` (exact
    match), and `tag` (set membership).

    Args:
        page (Union[Unset, int]):
        page_size (Union[Unset, int]):  Default: 50.
        q (Union[Unset, str]):
        category (Union[Unset, str]):
        tag (Union[Unset, str]):
        source (Union[Unset, str]):
        noted (Union[Unset, bool]):
        doc (Union[Unset, bool]):
        workspace (Union[Unset, str]):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[Union[Error, GetContentMarkdownResponse200]]
    """

    kwargs = _get_kwargs(
        page=page,
        page_size=page_size,
        q=q,
        category=category,
        tag=tag,
        source=source,
        noted=noted,
        doc=doc,
        workspace=workspace,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    *,
    client: AuthenticatedClient,
    page: Unset | int = UNSET,
    page_size: Unset | int = 50,
    q: Unset | str = UNSET,
    category: Unset | str = UNSET,
    tag: Unset | str = UNSET,
    source: Unset | str = UNSET,
    noted: Unset | bool = UNSET,
    doc: Unset | bool = UNSET,
    workspace: Unset | str = UNSET,
) -> Error | GetContentMarkdownResponse200 | None:
    """List/search the caller's markdown documents (metadata only)

     Lists the caller’s documents, most-recently-updated first. Optional filters narrow the set: `q`
    (free-text, case-insensitive substring across title, body, category, and tags), `category` (exact
    match), and `tag` (set membership).

    Args:
        page (Union[Unset, int]):
        page_size (Union[Unset, int]):  Default: 50.
        q (Union[Unset, str]):
        category (Union[Unset, str]):
        tag (Union[Unset, str]):
        source (Union[Unset, str]):
        noted (Union[Unset, bool]):
        doc (Union[Unset, bool]):
        workspace (Union[Unset, str]):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Union[Error, GetContentMarkdownResponse200]
    """

    return sync_detailed(
        client=client,
        page=page,
        page_size=page_size,
        q=q,
        category=category,
        tag=tag,
        source=source,
        noted=noted,
        doc=doc,
        workspace=workspace,
    ).parsed


async def asyncio_detailed(
    *,
    client: AuthenticatedClient,
    page: Unset | int = UNSET,
    page_size: Unset | int = 50,
    q: Unset | str = UNSET,
    category: Unset | str = UNSET,
    tag: Unset | str = UNSET,
    source: Unset | str = UNSET,
    noted: Unset | bool = UNSET,
    doc: Unset | bool = UNSET,
    workspace: Unset | str = UNSET,
) -> Response[Error | GetContentMarkdownResponse200]:
    """List/search the caller's markdown documents (metadata only)

     Lists the caller’s documents, most-recently-updated first. Optional filters narrow the set: `q`
    (free-text, case-insensitive substring across title, body, category, and tags), `category` (exact
    match), and `tag` (set membership).

    Args:
        page (Union[Unset, int]):
        page_size (Union[Unset, int]):  Default: 50.
        q (Union[Unset, str]):
        category (Union[Unset, str]):
        tag (Union[Unset, str]):
        source (Union[Unset, str]):
        noted (Union[Unset, bool]):
        doc (Union[Unset, bool]):
        workspace (Union[Unset, str]):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[Union[Error, GetContentMarkdownResponse200]]
    """

    kwargs = _get_kwargs(
        page=page,
        page_size=page_size,
        q=q,
        category=category,
        tag=tag,
        source=source,
        noted=noted,
        doc=doc,
        workspace=workspace,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    *,
    client: AuthenticatedClient,
    page: Unset | int = UNSET,
    page_size: Unset | int = 50,
    q: Unset | str = UNSET,
    category: Unset | str = UNSET,
    tag: Unset | str = UNSET,
    source: Unset | str = UNSET,
    noted: Unset | bool = UNSET,
    doc: Unset | bool = UNSET,
    workspace: Unset | str = UNSET,
) -> Error | GetContentMarkdownResponse200 | None:
    """List/search the caller's markdown documents (metadata only)

     Lists the caller’s documents, most-recently-updated first. Optional filters narrow the set: `q`
    (free-text, case-insensitive substring across title, body, category, and tags), `category` (exact
    match), and `tag` (set membership).

    Args:
        page (Union[Unset, int]):
        page_size (Union[Unset, int]):  Default: 50.
        q (Union[Unset, str]):
        category (Union[Unset, str]):
        tag (Union[Unset, str]):
        source (Union[Unset, str]):
        noted (Union[Unset, bool]):
        doc (Union[Unset, bool]):
        workspace (Union[Unset, str]):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Union[Error, GetContentMarkdownResponse200]
    """

    return (
        await asyncio_detailed(
            client=client,
            page=page,
            page_size=page_size,
            q=q,
            category=category,
            tag=tag,
            source=source,
            noted=noted,
            doc=doc,
            workspace=workspace,
        )
    ).parsed
